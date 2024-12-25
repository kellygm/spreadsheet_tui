# The Token abstraction used to produce useful error messages

class Token 
    attr_accessor :type, :source_txt, :start_index, :end_index
    def initialize(type, text, start, ending)
        @type = type 
        @source_txt = text
        @start_index = start
        @end_index = ending
    end
end