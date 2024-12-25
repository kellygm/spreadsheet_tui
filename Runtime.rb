# Manages collection of cells, i.e. holds a reference to a grid

require_relative 'Grid'

class Runtime 
    attr_reader :grid, :vars
    def initialize(grid)
        @grid = grid 
        @vars = Hash.new
    end
end