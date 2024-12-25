#
# Lexer abstraction, builds tokens
#

require_relative 'primitive'
require_relative 'evaluator'
require_relative 'grid'
require_relative 'operation'
require_relative 'token'


class Lexer 
    attr_reader :tokens

    def initialize(source)
        @source = source
        @i = 0 #position in source
        @tokens = [] #completed list of tokens
        @tokens_so_far = '' #help keep track of tokens seen so far
    end

    #see if characer 'c' exists in the source 
    # returns a boolean 
    def has(c) 
        @i < @source.length && @source[@i] == c
    end 
 
    # see if source contains ANY letter 
    def has_letter
        @i < @source.length && 'a' <= @source[@i] && @source[@i] <= 'z'
    end 

    # see if source contains a number
    def has_number
        @i < @source.length && (@source[@i] == '-' && @source[@i + 1] =~ /\d/ || @source[@i] =~ /\d/)
    end

    # check if source has decimal point
    def has_decimal
        @i < @source.length && '.' == @source[@i]
    end
 
    # add char at current index to token string 
    def capture
        @tokens_so_far += @source[@i]
        @i += 1
    end
 
    # don't include current index 
    def abandon
        @tokens_so_far = ''
        @i += 1
    end 
 
    # create a new token from the string and save it to the token 
    def emit_token(type, start_index, end_index)
        @tokens.push(Token.new(type, @tokens_so_far, start_index, end_index))
        # puts "pushed token: #{@tokens_so_far}"
        # puts "saved as: #{@tokens[start_index, end_index]}" 
        @tokens_so_far = ''
    end 

    # useful for debugging purpose, makes things neater
    def print_tokens
        for i in @tokens
            puts "type: #{i.type}, source_txt: '#{i.source_txt}', start_index: #{i.start_index}, end_index: #{i.end_index}\n"
        end
    end

    def lex
        while @i < @source.length
            if has('(')
                capture
                emit_token(:left_parenthesis, @i, @i)
            elsif has(')')
                capture
                emit_token(:right_parenthesis, @i, @i)
            elsif has('[')
                capture
                emit_token(:left_bracket, @i, @i)
            elsif has(']')
                capture
                emit_token(:right_bracket, @i, @i)
            elsif has(',')
                capture
                emit_token(:comma, @i, @i)
            elsif has('#')
                capture
                emit_token(:pound, @i, @i)
            #arithmetic tokens
            elsif has('+')
                capture
                emit_token(:plus, @i, @i)
            elsif has('-')
                start_idx = @i
                capture
                # see if directly followed by number 
                if @source[@i] =~ /\d/
                    while has_number || has_decimal
                        capture
                    end
                    emit_token(:int, start_idx, @i) if !@tokens_so_far.include?('.')
                    emit_token(:float, start_idx, @i) if @tokens_so_far.include?('.')
                else
                emit_token(:dash, @i, @i)
                end
            elsif has('*')
                capture
                # check for exponent **
                if has('*')
                    capture 
                    emit_token(:exponent, @i, @i)
                else
                    emit_token(:asterik, @i, @i)
                end
            elsif has('/')
                capture
                emit_token(:slash, @i, @i)
            elsif has('%')
                capture
                emit_token(:percent, @i, @i)
            # bitwise tokens
            elsif has('&')
                capture
                # check for logic '&&'
                if has('&')
                    start_index = @i
                    capture
                    emit_token(:logical_and, start_index, @i)
                else 
                    emit_token(:bitwise_and, @i, @i)
                end
            elsif has('|')
                capture
                # check for logic '||'
                if has('|')
                    start_index = @i
                    capture
                    emit_token(:logical_or, start_index, @i)
                else
                    emit_token(:bitwise_or, @i, @i)
                end
            elsif has('=')
                capture
                start_index = @i
                emit_token(:equals, @i, @i)
            elsif has('!')
                capture
                if has('=')
                    start_index = @i
                    capture 
                    emit_token(:not_equals, start_index, @i)
                else
                emit_token(:logical_not, @i, @i)
                end
            elsif has("~")
                capture 
                emit_token(:btiwise_not, @i, @i)
            elsif has('^')
                capture
                emit_token(:xor, @i, @i)
            elsif has('<')
                capture
                # check for <<
                if has('<')
                    start_index = @i
                    capture
                    emit_token(:left_shift, start_index, @i)
                # check for <=
                elsif has('=')
                    start_index = @i
                    capture
                    emit_token(:less_equals, start_index, @i)
                else
                    emit_token(:less_than, @i, @i)
                end
            elsif has('>')
                capture 
                # check for right shift >>
                if has('>')
                    start_index = @i
                    capture
                    emit_token(:right_shift, start_index, @i)
                # check for >=
                elsif has('=')
                    start_index = @i
                    capture
                    emit_token(:greater_equals, start_index, @i)
                else
                    emit_token(:greater_than, @i, @i)
                end
            elsif has("\n")
                capture
                emit_token(:linebreak, @i, @i)
            #handle letter based tokens
            elsif has_letter
                start_index = @i
                while has_letter
                    capture
                end
                keyword = @tokens_so_far.downcase
                if keyword == 'max'
                    emit_token(:max, start_index, @i)
                elsif keyword == 'sum'
                    emit_token(:sum, start_index, @i)
                elsif keyword == 'mean'
                    emit_token(:mean, start_index, @i)
                elsif keyword == 'min'
                    emit_token(:min, start_index, @i)
                elsif keyword == 'true'
                    emit_token(:true, start_index, @i)
                elsif keyword == 'false' 
                    emit_token(:false, start_index, @i)
                elsif keyword == 'float'
                    emit_token(:to_f, start_index, @i)
                elsif @tokens_so_far == 'int'
                    emit_token(:to_i, start_index, @i)
                elsif @tokens_so_far == 'boolean'
                    emit_token(:bool, start_index, @i)
                elsif @tokens_so_far == 'string'
                    emit_token(:str, start_index, @i) #just plain string
                else
                    emit_token(:etc, start_index, @i)
                end
            #check for floats 
            elsif has_number
            startInd = @i
            float = false
            capture if @source[@i] == '-' # capture neg sign 
            while has_number || has_decimal
                if has_decimal
                    float = true
                    capture
                else 
                    capture
                end
            end
            if float
                emit_token(:float, startInd, @i)
            else 
                emit_token(:int, startInd, @i)
            end
        elsif has(' ')
            abandon
        end
            # Skip whitespaces
        end

        @tokens # finally.. return all the collected tokens (whew)
    end



end

lexer = Lexer.new("2.0")
tokens = lexer.lex
puts lexer.print_tokens