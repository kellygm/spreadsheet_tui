# Manages collection of cells, i.e. holds a reference to a grid

require_relative 'grid'

class Runtime 
    attr_reader :grid, :vars
    def initialize(grid)
        @grid = grid 
        @vars = {}
    end

    # get variable in runtime dictionary (vars) that has passed identifier
    def get_variable(identifier)
        @vars[identifier]
    end

    def set_variable(identifier, primitive)
        @vars[identifier] = primitive
    end

    def print_vars
        for var in @vars
            puts "#{var}"
        end
    end
end