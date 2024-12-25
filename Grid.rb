require_relative 'primitive'
require_relative 'evaluator'
require_relative 'serializer'
require_relative 'operation'

# a Grid abstraction that manages all the cells 

class Cell 
    attr_accessor :value, :type
    def initialize(value)
        @value = value
        @type = type
    end
end

class Grid
    attr_accessor :rows, :columns, :grid # just in case 
    def initialize(rows, columns)
        @grid = Array.new(rows) {Array.new(columns, IntegerPrimitive.new(0))}
    end
    # stores an ast at the passed cell address
    def set_grid(addr, tree)
        row = addr.row.traverse(Evaluator.new, nil).value
        col = addr.col.traverse(Evaluator.new, nil).value
        @grid[row][col] = tree
    end

    # accepts cell address and returns cell's model primitive
    def get_grid(addr)
        row = addr.row.traverse(Evaluator.new, nil).value
        col = addr.col.traverse(Evaluator.new, nil).value
        # puts "Accessing grid at row: #{row} , column: #{col}...\n"
        value = @grid[row][col]
        # puts "Retrieved value: #{value.value}"
        # puts
        value
    end




end