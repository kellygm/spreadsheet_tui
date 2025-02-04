#
# Encapsulation for primitive class objects.
#

class Primitive 
    attr_reader :value
    def initialize(value)
        @value = value
    end
end

class Cells
    attr_accessor :row, :col 
    def initialize(row, col)
        @row = row
        @col = col
    end
end

class IntegerPrimitive < Primitive
    def traverse(visitor, payload)
         visitor.visit_integer(self, payload)
    end
end

class FloatPrimitive < Primitive
    def traverse(visitor, payload)
        visitor.visit_float(self, payload)
    end
end

class BooleanPrimitive < Primitive
    def traverse(visitor, payload)
        visitor.visit_bool(self, payload)
    end
end

class StringPrimitive < Primitive
    def traverse(visitor, payload)
        visitor.visit_string(self, payload)
    end
end

# the celladdress primitive takes an array instead of two separate variables
class CellAddressPrimitive
    attr_accessor :col, :row, :value
    def initialize(row, col)
        @row = row
        @col = col
        @value = [row, col]
    end
    def traverse(visitor, payload)
        visitor.visit_celladdr(self, payload)
    end
end

# pair of column and row expressions that yields the value at its address when evaluted
class CellRValue < Cells
    def traverse(visitor, payload)
        visitor.visit_rvalue(self, payload)
    end
end

# pair of column and row expressions that yields an address primitve when evaluated
class CellLValue < Cells
    def traverse(visitor, payload)
        visitor.visit_lvalue(self, payload)
    end
end
