#
# Encapsulation of Operations that can be performed on primitives.
#

class BinaryOperation
    attr_accessor :left, :right
    def initialize(left, right)
        @left = left
        @right = right
    end
end

class UnaryOperation
    attr_accessor :value
    def initialize(value)
        @value = value
    end
end

class StatOperation
    attr_accessor :topleft, :btmright
    def initialize(cell1, cell2)
        @topleft = cell1
        @btmright = cell2
    end
end
# -------------------------------------------
# Binary Operations
# -------------------------------------------
class Add < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_add(self, payload)
    end
end

class Subtract < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_sub(self, payload)
    end
end

class Multiply < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_multiply(self, payload)
    end
end

class Divide < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_divide(self, payload)
    end
end

class Exponent < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_exp(self, payload)
    end
end

class Modulo < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_modulo(self, payload)
    end
end

class LogicAnd < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_log_and(self, payload)
    end
end

class LogicOr < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_log_or(self, payload)
    end
end

class BitwiseAnd < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_bit_and(self, payload)
    end
end

class BitwiseOr < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_bit_or(self, payload)
    end
end

class BitwiseXor < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_bit_xor(self, payload)
    end
end

class LeftShift < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_lshift(self, payload)
    end
end

class RightShift < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_rshift(self, payload)
    end
end

class Equals < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_equals(self, payload)
    end
end

class NotEquals < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_not_equals(self, payload)
    end
end

class GreaterThan < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_greater_than(self, payload)
    end
end

class LessThan < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_less_than(self, payload)
    end
end

class GreaterEquals < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_greater_equals(self, payload)
    end
end

class LessEquals < BinaryOperation
    def traverse(visitor, payload)
        visitor.visit_less_equals(self, payload)
    end
end

class Max < StatOperation
    def traverse(visitor, payload)
        visitor.visit_max(self, payload)
    end  
end

class Min < StatOperation
    def traverse(visitor, payload)
        visitor.visit_min(self, payload)
    end  
end

class Mean < StatOperation
    def traverse(visitor, payload)
        visitor.visit_mean(self, payload)
    end  
end

class Sum < StatOperation
    def traverse(visitor, payload)
        visitor.visit_sum(self, payload)
    end
end

# -------------------------------------------
# Unary Operations
# -------------------------------------------
class BitwiseNot < UnaryOperation
    def traverse(visitor, payload)
        visitor.visit_bit_not(self, payload)
    end
end

class Negation < UnaryOperation
    def traverse(visitor, payload)
        visitor.visit_negate(self, payload)
    end
end

class LogicNot < UnaryOperation
    def traverse(visitor, payload)
        visitor.visit_log_not(self, payload)
    end
end

class FloatToInt < UnaryOperation
    def traverse(visitor, payload)
        visitor.visit_float_to_int(self, payload)
    end 
end

class IntToFloat < UnaryOperation
    def traverse(visitor, payload)
        visitor.visit_int_to_float(self, payload)
    end
end

# -------------------------------------------
# Loops
# -------------------------------------------
class Conditional
    attr_accessor :condition, :if_block, :else_block
    def initialize(cond, block1, block2)
        @condition = cond
        @block1 = if_block
        @block2 = else_block
    end
    
    def traverse(visitor, payload)
        visitor.visit_conditional(self, payload)
    end
end

class ForLoop
    attr_accessor :iter, :start_addr, :end_addr, :block
    def initialize(iter, start, ending, block)
        @iter = iter
        @start_addr = start
        @end_addr = ending
        @block = block 
    end

    def traverse(visitor, payload)
        visitor.visit_loop(self, payload)
    end

end