require_relative 'primitive'
require_relative 'operation'
require_relative 'evaluator'
require_relative 'lexer'
require_relative 'serializer'
require_relative 'grid'

#Parser abstraction. Accepts a list of tokens and assembles an AST using the 
#model abstractions.

# This parser is organized from lowest to highest precedence based on the grammar 

class Parser
    def initialize(lex)
        @lex = lex
        @tokens = @lex.lex
        @i = 0
    end

#-----------------------------------------------
# HELPER METHODS :)
#-----------------------------------------------

    # see if next token has a desired type
    def has(type)
        @i < @tokens.length && @tokens[@i].type == type
    end

    # move forward if curr token in list; return the token just visited
    def advance
        curr_token = @tokens[@i]
        @i += 1
        curr_token
    end

    # parse the complete list of tokens 
    # and return the root node of the AST
    def parse 
        root = parse_block
        if @i < @tokens.length
            raise TypeError.new("Found unsupported token  '#{@tokens[@i].source_txt}' at index #{@i}\n")
        end
        root 
    end

    # parse a block of statements
    def parse_block
        block = Block.new
        # skip '{'
        if has(:left_curly)
            advance
        else
            raise "Expected '{' at beginning of block"
        end
        while @i < @tokens.length && !has(:right_curly)
            block.add_statement(parse_statement)
        end
        # skip '}'
        if has(:right_curly)
            advance
        else
            raise "Expected '}' at end of block"
        end
        block
    end

    # parse a single statement
    def parse_statement
        if has (:identifier)
            parse_assignment
        elsif has (:if)
            parse_conditional
        elsif has (:for)
            parse_for_loop
        else 
            parse_expression
        end
    end

    # parse an assignment statement
    def parse_assignment
        id = advance.source_txt
        raise "Expected '=' after variable name" unless has(:equals)
        advance # skip '='
        right = parse_expression
        Assignment.new(id, right)
    end

    # parse a conditional block
    def parse_conditional
        advance # skip 'if'
        condition = parse_expression
        if_block = parse_block
        if has(:else)
            advance # skip 'else'
            else_block = parse_block
        else
            else_block = nil
        end
        advance # skip 'end'
        Conditional.new(condition, if_block, else_block)
    end

    # parse a for loop block
    def parse_for_loop
        advance # skip 'for'
        iter = advance.source_txt
        raise "Expected 'in' after iterator" unless has(:in)
        advance # skip 'in'
        start_addr = parse_expression
        raise "Expected '..' after start address" unless has(:elipsis)
        advance # skip '..'
        end_addr = parse_expression
        block = parse_block
        advance # skip 'end'
        ForLoop.new(iter, start_addr, end_addr, block)
    end

    # parse expression
    def parse_expression
        parse_logic
    end

    #----------------------------------------
    # Logical operations 
    #----------------------------------------

    # parse logical expressions (AND and OR)
    def parse_logic
        left = parse_logic_or
        while has(:logical_or)
            curr_token = advance
            right = parse_logic_or
            left = LogicOr.new(left, right)
        end
        left
    end

    def parse_logic_or
        left = parse_logic_and
        while has(:logical_and)
            curr_token = advance
            right = parse_logic_and
            left = LogicAnd.new(left, right)
        end
        left
    end


    def parse_logic_and
        left = parse_bitwise
        while has(:bitwise_and)
            curr_token = advance
            right = parse_bitwise
            left = LogicAnd.new(left, right)
        end
        left
    end

    #----------------------------------------
    # Bitwise operations 
    #----------------------------------------

    # def parse_bitwise
    #     left = parse_bitwise
    #     while peek == :bitwise_xor || peek == :bitwise_or
    #         operation = consume(peek)
    #         right = rel_equals
    #         case operation.type
    #         when :bitwise_xor
    #             left = BinaryOperation::BitwiseXor.new(left, right)
    #         when :bitwise_or 
    #             left = BinaryOperation::BitwiseOr.new(left, right)
    # end

    # parse bitwise expressions (XOR, AND, and OR)
    def parse_bitwise
        left = parse_rel_equals
        while has(:xor) || has(:bitwise_or) || has(:bitwise_and)
            operator = advance
            right = parse_rel_equals
            case operator.type
            when :xor
                left = BitwiseXor.new(left, right)
            when :bitwise_or
                left = BitwiseOr.new(left, right)
            when :bitwise_and
                left = BitwiseAnd.new(left,right)
            end
        end
        left
    end

    #----------------------------------------
    # Bitwise operations 
    #----------------------------------------

    # parse expressions that have '=' or '!=' sign
    def parse_rel_equals
        left = parse_rel_operations
        while has(:equals) || has(:not_equals)
            advance
            right = parse_rel_operations
            if has(:equals)
                left = Equals.new(left, right)
            elsif has(:not_equals)
                left = NotEquals.new(left, right)
            end
        end
        left
    end

    # parse comparision operations  
    def parse_rel_operations
        # puts "Parsing relational operations"
        left = parse_bit_shifts
        while has(:less_equals) || has(:less_than) || has(:greater_than) || has(:greater_equals)
            operator = advance
           # puts "Found relation operator #{operator.source_txt}"
            right = parse_bit_shifts
            case operator.type
            when :less_than
                left = LessThan.new(left, right)
            when :less_equals
                left = LessEquals.new(left, right)
            when :greater_than
                left = GreaterThan.new(left, right)
            when :greater_equals
                left = GreaterEquals.new(left, right)
            end
        end
        left
    end

    # for left and right bit shifting 
    def parse_bit_shifts
        left = parse_arithmetic_ops
        while has(:left_shift) || has(:right_shift)
            operator = advance # save operator
            right = parse_arithmetic_ops
            case operator.type
            when :left_shift
                left = LeftShift.new(left, right)
            when :right_shift
                left = RightShift.new(left, right)
            end
        end
        left
    end

    #----------------------------------------
    # Arithmetic operations 
    #----------------------------------------
    def parse_arithmetic_ops
        left = parse_multiplication_ops
        while has(:plus) || has(:dash)
            operator = advance
            right = parse_multiplication_ops
            case operator.type
            when :plus 
                left = Add.new(left, right)
            when :dash
                left = Subtract.new(left, right)
            end
        end
        left
    end

    def parse_multiplication_ops
        left = parse_exponent_op
        while has(:asterik) || has(:slash) || has(:percent)
           operator = advance
            right = parse_exponent_op
            case operator.type
            when :asterik
                left = Multiply.new(left, right)
            when :slash
                left = Divide.new(left, right)
            when :percent
                left = Modulo.new(left, right)
            end

        end
        left
    end
    
    def parse_exponent_op
        left = parse_negation_op
        while has(:exponent)
            advance # skip **
            right = parse_negation_op
            left = Exponent.new(left, right)
        end
        left
    end

    # parse logical and bitwise not 
    def parse_negation_op
        if has(:logical_not)
            advance # skip !
            value = parse_negation_op
            LogicNot.new(value)
        elsif has(:btiwise_not)
            advance # skip ~
            value = parse_negation_op
            BitwiseNot.new(value)
        elsif has(:dash)
            advance # skip -
            value = parse_negation_op
            Negation.new(value)
        else
            parse_primitives
        end
    end

#---------------------------------------------
# Parsing Primitives
#---------------------------------------------
    def parse_primitives
        # see parenthesis 
        if has(:left_parenthesis)
            parse_paren_exp
        elsif has(:int)
            curr_token = advance
            IntegerPrimitive.new(curr_token.source_txt.to_i)
        elsif has(:float)
            curr_token = advance
            FloatPrimitive.new(curr_token.source_txt.to_f)
        elsif has(:true) || has(:false)
            curr_token = advance
            BooleanPrimitive.new(curr_token.source_txt.downcase == "true")
        elsif has(:left_bracket) || has(:pound)
            parse_celladdr
        elsif has(:max) || has(:sum) || has(:mean) || has(:min)
            parse_stat_ops
        elsif has(:to_i) || has(:to_f)
            parse_casting
        elsif has(:str)
            curr_token = advance
            StringPrimitive.new(curr_token.source_txt)
        elsif has(:identifier)
            parse_variable_ref
        else
            raise "Unsupported token: #{has(:etc)}  with value #{@tokens[@i] ? @tokens[@i].source_txt : 'EOF'} at index #{@i}"
        end
    end

    # parse variable reference
    def parse_variable_ref
        var = advance.source_txt
        VariableReference.new(var)
    end

    # parse cell address primitive, either brackets or with pound symbol
    def parse_celladdr
        if has(:pound)
            advance # go past the pound sign'
            raise "Expected left bracket [" unless has(:left_bracket)
            advance # skip '['
            left = parse_expression
            raise "Expected a comma after first part of cell addr, found #{@tokens[@i].source_txt}" unless has(:comma)
            advance # skip ,
            right = parse_expression
            raise "Expected a right bracket after second part of cell addr, found #{@tokens[@i].source_txt}" unless has(:right_bracket)
            advance # skip ]
            # exp = CellAddressPrimitive.new(left, right)
            # exp
            CellRValue.new(left, right)
        else
            raise "Expected left bracket [" unless has(:left_bracket)
            advance # skip '['
            left = parse_expression
            raise "Expected a comma after first part of cell addr, found #{@tokens[@i].source_txt}" unless has(:comma)
            advance # skip ,
            right = parse_expression
            raise "Expected a right bracket after second part of cell addr, found #{@tokens[@i].source_txt}" unless has(:right_bracket)
            advance
            CellLValue.new(left, right)
        end
    end

    # parse statistical operations
    def parse_stat_ops
        operator = advance
        raise "Expected left parenthesis after #{operator.source_txt}" unless has(:left_parenthesis)
        advance # skip (
        left = parse_celladdr # parse first arg
        raise "Expected comma between arguments" unless has(:comma)
        advance # skip ,
        right = parse_celladdr
        raise "Expected right parenthesis after arguments" unless has(:right_parenthesis)
        advance # skip )
        case operator.type
        when :sum
            raise "Both arguments must be CellLValues" unless left.is_a?(CellLValue) && right.is_a?(CellLValue)
            Sum.new(left, right)
        when :min
            Min.new(left, right)
        when :max 
            Max.new(left, right)
        when :mean
            Mean.new(left, right)
        else 
            raise "Unsupported statistical function #{operator.source_txt}"
        end
    end

    # if parenthesis in expression, parse that first
    def parse_paren_exp
        advance # go into left paren
        exp = parse_expression # parse what's inside 
        if has(:right_parenthesis)
            advance
        else 
            raise "Expected closing parenthesis"
        end
        exp 
    end

    # parse casting operations 
    def parse_casting
        operator = advance
        raise "Expected left parenthesis after #{operator.type}" unless has(:left_parenthesis)
        cast_type = @tokens[@i-1].type # get type of cast operation
        advance # skip (    
        cast_exp = parse_expression # parse exp inside 
        raise "Expected right parenthesis after expression" unless has(:right_parenthesis)
        advance # skip )
        case operator.type 
        when :to_f
            IntToFloat.new(cast_exp)
        when :to_i
            FloatToInt.new(cast_exp)
        else 
            raise "Unsupported casting operation: #{operator.source_txt}"
        end
    end

end