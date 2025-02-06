# this class recurses through an expression and its operands 
# to produce a primitive

# Assert the following... 
# --- arithmetic operations have numeric operands that are compatiable 
# --- logical operations have boolean operands 
# --- bultin functions have cell lvaules operands 

require_relative 'operation'
require_relative 'primitive'
require_relative 'serializer'

class Evaluator 

# ----------------------------------------------------------------------------
# HELPER FUNCTIONS
# ----------------------------------------------------------------------------
    def convert_to_num(primitive)
        if primitive.is_a?(IntegerPrimitive) || primitive.is_a?(FloatPrimitive)
            primitive.value
        else
            nil
        end
    end

    # validating for arithmetic operations that require integers or floats
    def validate_primitives(x, y)
        #evaluate left node to model primitive
        unless x.is_a?(IntegerPrimitive) || x.is_a?(FloatPrimitive)
            raise ArgumentError, "the type of x is not supported (must be IntegerPrimitive or FloatPrimitive)"
        end
        #evalute right node to model primitive 
        unless y.is_a?(IntegerPrimitive) || y.is_a?(FloatPrimitive)
            raise ArgumentError, "the type of y is not supported (must be IntegerPrimitive or FloatPrimitive)"
        end
    end

    # validating type for bitwise operations 
    def type(node)
        if node.is_a?(IntegerPrimitive)
            node.int
        elsif node.is_a?(FloatPrimitive)
            node.float
        elsif node.is_a?(BooleanPrimitive)
            node.bool
        elsif node.is_a?(StringPrimitive)
            node.str
        elsif node.is_a?(CellAddressPrimitive)
            node.value
        else
            raise TypeError, "Type is not supported"
        end
    end

# ----------------------------------------------------------------------------
# ARITHMETIC 
# ----------------------------------------------------------------------------
    def visit_integer(node, runtime)
        node
    end

    def visit_float(node, runtime)
        node
    end

    def visit_bool(node, runtime)
        node
    end

    def visit_string(node, runtime)
        node
    end

    def visit_celladdr(node, runtime)
        node
    end

    # return the value at the cell address 
    def visit_rvalue(node, runtime)
        col = node.col.traverse(self, runtime)
        row = node.row.traverse(self, runtime)
        # CellAddressPrimitive.new(IntegerPrimitive.new(row.value), IntegerPrimitive.new(col.value))
        # add lookup 
        addr = CellAddressPrimitive.new(IntegerPrimitive.new(row.value), IntegerPrimitive.new(col.value))
        runtime.grid.get_grid(addr) # return the entire primitive
    end

    # return a cell address
    def visit_lvalue(node, runtime)
        col = node.col.traverse(self, runtime)
        row = node.row.traverse(self, runtime)
        # type check!
        if (col.is_a?(BooleanPrimitive) || col.is_a?(StringPrimitive))
                raise TypeError, "Invalid type of CellL col #{col.type}, only Integers allowed"
        end
        if (row.is_a?(BooleanPrimitive) || row.is_a?(StringPrimitive))
                raise TypeError, "Invalid type of CellL row #{row.type}, only Integers allowed"
        end
        CellAddressPrimitive.new(IntegerPrimitive.new(row.value), IntegerPrimitive.new(col.value))
    end

    def visit_add(node, runtime)
        a = node.left.traverse(self, runtime)
        b = node.right.traverse(self, runtime)
        # check operand types and convert sum primitive appropriately 
        if a.is_a?(IntegerPrimitive) && b.is_a?(IntegerPrimitive)
            a = convert_to_num(a)
            b = convert_to_num(b)
            return IntegerPrimitive.new(a + b)
        elsif a.is_a?(FloatPrimitive) && b.is_a?(FloatPrimitive)
            a = convert_to_num(a)
            b = convert_to_num(b)
            return FloatPrimitive.new(a + b)
        elsif a.is_a?(FloatPrimitive) && b.is_a?(IntegerPrimitive)
            a = convert_to_num(a)
            b = convert_to_num(b)
            return FloatPrimitive.new(a + b)
        elsif a.is_a?(IntegerPrimitive) && b.is_a?(FloatPrimitive)
            a = convert_to_num(a)
            b = convert_to_num(b)
            return FloatPrimitive.new(a + b)
        else
            raise TypeError, "operand type of #{a} or #{b} is not supported for ADD"
        end         
    end
    
    def visit_sub(node, runtime)
        a = node.left.traverse(self, runtime)
        b = node.right.traverse(self, runtime)
        # convert to num to perform operation 
        validate_primitives(a, b)
        a = convert_to_num(a)
        b = convert_to_num(b)
        # convert sum to proper primitive
        if a.is_a?(Integer) && b.is_a?(Integer)
            return IntegerPrimitive.new(a - b)
        elsif a.is_a?(FloatPrimitive) && b.is_a?(FloatPrimitive) 
            return FloatPrimitive.new(a - b)
        else
            raise TypeError, "Unsupported type #{a} or #{b} for SUB"
        end
    end

    def visit_multiply(node, runtime)
        a = node.left.traverse(self, runtime)
        b = node.right.traverse(self, runtime)
        # puts "type of a: #{a}"
        # puts "type of b: #{b}"

        # if a.is_a?(CellAddressPrimitive)
        #     row = a.row.traverse(self, runtime)
        #     col = a.col.traverse(self, runtime)
        #     a_val = runtime.grid.get_grid(a).value
        #     # puts "got cell value: #{a_val}"
        # else
        #     a_val = convert_to_num(a)
        # end

        a_val = convert_to_num(a)
        b_val = convert_to_num(b)

        # puts "value of a: #{a_val}"
        # puts "value of b: #{b_val}"

        if a_val == nil || b_val == nil 
            raise TypeError, "one of the operands is not a number"
        end

        if a_val.is_a?(Integer) && b_val.is_a?(Integer)
            return IntegerPrimitive.new(a_val * b_val)
        elsif a_val.is_a?(Float) || b_val.is_a?(Float)
            return FloatPrimitive.new(a_val * b_val)
        else 
            raise TypeError, "Unsupported type for operation MULTIPLY"
        end
    end

    def visit_divide(node, runtime)
        a = node.left.traverse(self, runtime)
        b = node.right.traverse(self, runtime)

        a = convert_to_num(a)
        b = convert_to_num(b)
        if a.is_a?(Integer) && b.is_a?(Integer)
            return IntegerPrimitive.new(a / b)
        elsif a.is_a?(Float) || b.is_a(Float)
            return FloatPrimitive.new(a / b)
        else 
            raise TypeError, "Unsupported type for operation DIVIDE"
        end
    end

    def visit_exp(node, runtime)
        a = node.left.traverse(self, runtime)
        b = node.right.traverse(self, runtime)
        a = convert_to_num(a)
        b = convert_to_num(b)
        if a.is_a?(Integer) && b.is_a?(Integer)
            return IntegerPrimitive.new(a ** b)
        elsif a.is_a?(Float) || b.is_a?(Float)
            return FloatPrimitive.new(a ** b)
        else 
            raise TypeError, "The type of the node is not supported for EXPONENT"
        end
    end

    def visit_modulo(node, runtime)
        a = node.left.traverse(self, runtime)
        b = node.right.traverse(self, runtime)
        a = convert_to_num(a)
        b = convert_to_num(b)
        if a.is_a?(Integer) && b.is_a?(Integer)
            return IntegerPrimitive.new(a % b)
        elsif a.is_a?(Float) || b.is_a?(Float)
            return FloatPrimitive.new(a % b)
        else
            raise TypeError, "The type of the node(a: #{a}, b: #{b}) is not supported for MODULO"
        end
    end

    def  visit_negate(node, runtime)
        if node.value.is_a?(CellRValue)
            row = node.value.row.traverse(self, runtime)
            col = node.value.col.traverse(self, runtime)
            # puts "#{row.value}, #{col.value}"
            cell_value = runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(row.value), IntegerPrimitive.new(col.value)))
            # puts "cell value is: #{cell_value.value}"
            if cell_value.is_a?(IntegerPrimitive)
                return IntegerPrimitive.new(-(cell_value.value))
            elsif cell_value.is_a?(FloatPrimitive)
                return FloatPrimitive.new(-(cell_value.value))
            else
                raise TypeError, "Only integer and floats are accepted for NEGATION"
            end
        end
        node_val = node.value.traverse(self, runtime)
        if node_val.is_a?(IntegerPrimitive)
            return IntegerPrimitive.new(-node_val.value)

        elsif node_val.is_a?(FloatPrimitive)
            return FloatPrimitive.new(-node_val.value)
        else
            raise TypeError, "Only integer and floats are accepted for NEGATION"
        end
    end

# ----------------------------------------------------------------------------
# LOGICAL: must have boolean operands   
# ----------------------------------------------------------------------------
    def visit_log_and(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        unless left.is_a?(BooleanPrimitive) && right.is_a?(BooleanPrimitive)
            raise TypeError, "Logic operands for AND must be booleans "
        end
        BooleanPrimitive.new((left.value && right.value))
    end

    def visit_log_or(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)        
        unless left.is_a?(BooleanPrimitive) && right.is_a?(BooleanPrimitive)
            raise TypeError, "Logic operands for OR must be booleans "
        end
        BooleanPrimitive.new((left.value || right.value))
    end

    def visit_log_not(node, runtime)
        value = node.value.traverse(self, runtime)
        unless value.is_a? (BooleanPrimitive)
            raise TypeError, "Logic operands for NOT must be booleans "
        end
        BooleanPrimitive.new(!value.value)
    end


# ----------------------------------------------------------------------------
# BITWISE: must have integer operands  
# ----------------------------------------------------------------------------
    def visit_bit_and(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        unless left.is_a?(IntegerPrimitive) && right.is_a?(IntegerPrimitive)
            raise TypeError, "Bitwise operands for AND must be integers "
        end
        IntegerPrimitive.new(left.value & right.value)
    end
    
    def visit_bit_or(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        unless left.is_a?(IntegerPrimitive) && right.is_a?(IntegerPrimitive)
            raise TypeError, "Bitwise operands for OR must be integers "
        end
        IntegerPrimitive.new(left.value | right.value)
    end

    def visit_bit_not(node, runtime)
        left = node.value.traverse(self, runtime)
        unless left.is_a?(IntegerPrimitive)
            raise TypeError, "Bitwise operands for NOT must be integers "
        end
        IntegerPrimitive.new(~left.value)
    end

    def visit_bit_xor(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        unless left.is_a?(IntegerPrimitive) && right.is_a?(IntegerPrimitive)
            raise TypeError, "Bitwise operands for XOR must be integers "
        end
        IntegerPrimitive.new(left.value ^ right.value)
    end

    def visit_lshift(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        # puts "Left: #{left}"
        # puts "Right: #{right}"
        if left.is_a?(CellAddressPrimitive) && right.is_a?(IntegerPrimitive)
            # get value at cell
            row = left.row.traverse(self, runtime).value
            col = left.col.traverse(self, runtime).value
            # puts "left is cell [#{row}, #{col}]"
            addr = CellAddressPrimitive.new(IntegerPrimitive.new(row), IntegerPrimitive.new(col))
            cell_value = runtime.grid.get_grid(addr)
            # puts "value at cell [#{row}, #{col}]: #{cell_value.value}"
            # puts "value to shift is: #{right.value}"
            result = IntegerPrimitive.new(cell_value.value << right.value)
            return result
        end

        if left.is_a?(IntegerPrimitive) && right.is_a?(IntegerPrimitive)
            result = IntegerPrimitive.new(left.value << right.value)
            return result
        else 
            raise TypeError, "Left-Shift values must be integers"
        end
    end
    
    def visit_rshift(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)

        if left.is_a?(CellAddressPrimitive) && right.is_a?(IntegerPrimitive)
            row = left.row.traverse(self, runtime).value
            col = left.col.traverse(self, runtime).value
            addr = CellAddressPrimitive.new(IntegerPrimitive.new(row), IntegerPrimitive.new(col))
            cell_value = runtime.grid.get_grid(addr)        
            result = IntegerPrimitive.new(cell_value.value >> right.value)
            return result
        end

        if left.is_a?(IntegerPrimitive) && right.is_a?(CellAddressPrimitive)
            row = right.row.traverse(self, runtime).value
            col = right.col.traverse(self, runtime).value
            addr = CellAddressPrimitive.new(IntegerPrimitive.new(row), IntegerPrimitive.new(col))
            cell_value = runtime.grid.get_grid(addr)        
            result = IntegerPrimitive.new(left.value >> cell_value.value)
            return result
        end

        if left.is_a?(IntegerPrimitive) && right.is_a?(IntegerPrimitive)
            # perform right shift
            result = IntegerPrimitive.new(left.value >> right.value)
            return result
        else 
            raise TypeError, "Right-Shift values must be integers"
        end

    end

# ----------------------------------------------------------------------------
# RELATION: supports r and lvalues  
# ----------------------------------------------------------------------------    

    def visit_equals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)  
        BooleanPrimitive.new((convert_to_num(left) == convert_to_num(right)))
    end

    def visit_not_equals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)   
        BooleanPrimitive.new((convert_to_num(left) != convert_to_num(right))) 
    end

    def visit_greater_than(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)   
        BooleanPrimitive.new((convert_to_num(left) > convert_to_num(right)))
    end

    def visit_greater_equals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        BooleanPrimitive.new((convert_to_num(left) >= convert_to_num(right)))
    end

    def visit_less_than(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)

        if left.is_a?(IntegerPrimitive) && right.is_a?(IntegerPrimitive)
            return BooleanPrimitive.new((left.value.to_i < right.value.to_i))
        elsif left.is_a?(FloatPrimitive) && right.is_a?(FloatPrimitive)
            return BooleanPrimitive.new((left.value.to_f < right.value.to_f))
        elsif left.is_a?(FloatPrimitive) && right.is_a?(IntegerPrimitive) || left.is_a?(IntegerPrimitive) && right.is_a?(FloatPrimitive)
            return BooleanPrimitive.new(left.value.to_f < right.value.to_f)
        else
        # Check for cell address primitives
        left_val = left.is_a?(CellAddressPrimitive) ? runtime.grid.get_grid(left) : left.value
        right_val = right.is_a?(CellAddressPrimitive) ? runtime.grid.get_grid(right) : right.value
        return BooleanPrimitive.new(convert_to_num(left_val) < convert_to_num(right_val))
        end
    end

    def visit_less_equals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)   
        BooleanPrimitive.new((left.value.to_i <= right.value.to_i))
    end

    def visit_int_to_float(node, runtime)
        unless node.value.is_a?(IntegerPrimitive)
            raise ArgumentError, "Only integers can be accepted"
        end
        value = convert_to_num(node.value)
        FloatPrimitive.new(value.to_f)
    end

    def visit_float_to_int(node, runtime)
        unless node.value.is_a?(FloatPrimitive)
            raise ArgumentError, "Only floats can be accepted"
        end
        value = convert_to_num(node.value)
        IntegerPrimitive.new(value.to_i)
    end

# ----------------------------------------------------------------------------------------------------
# STATISTICS: statistical functions all accept two cell lvalues representing 
# the top-left cell and the bottom-right cell of a rectangular area over which the value is computed  
# ----------------------------------------------------------------------------------------------------
def visit_max(node, runtime)
        a = node.topleft
        b = node.btmright
        maxValue = runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(a.row.value), IntegerPrimitive.new(a.col.value))).value
        
        (a.row.value..b.row.value).each do |x| 
            (a.col.value..b.col.value).each do |y|
                address = CellAddressPrimitive.new(IntegerPrimitive.new(x), IntegerPrimitive.new(y))
                cell = runtime.grid.get_grid(address)
                if cell.is_a?(IntegerPrimitive) || cell.is_a?(FloatPrimitive)
                    maxValue = [cell.value.to_f, maxValue].max
                end
            end
        end
        FloatPrimitive.new(maxValue.round(2))
    end

    # evalutes the min value in the range betwen the top left and bottom right cells of the grid
    def visit_min(node, runtime)
        a = node.topleft
        b = node.btmright
        start = CellAddressPrimitive.new(IntegerPrimitive.new(a.row.value), IntegerPrimitive.new(a.col.value))
        minValue = runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(a.row.value), IntegerPrimitive.new(a.col.value))).value  # default min value to topleft cell value 
        

        (a.row.value..b.row.value).each do |x|
            (a.col.value..b.col.value).each do |y|
                address = CellAddressPrimitive.new(IntegerPrimitive.new(x), IntegerPrimitive.new(y))
                cell = runtime.grid.get_grid(address)
                # puts "value at cell [#{x}, #{y}] is... #{cell.value}"
                # only include numerical primitives in calculation 
                if cell.is_a?(IntegerPrimitive) || cell.is_a?(FloatPrimitive)
                    minValue = [cell.value.to_f, minValue].min
                end
                # puts "current min value is... #{minValue}"
            end
        end
        FloatPrimitive.new(minValue.round(2))
    end

    def visit_mean(node, runtime)
        a = node.topleft
        b = node.btmright
        items = 0 # keep track of how many cells in range 
        product = 0 # holds sum of values in cell range
        (a.row.value..b.row.value).each do |x|
            (a.col.value..b.col.value).each do |y|
                address = CellAddressPrimitive.new(IntegerPrimitive.new(x), IntegerPrimitive.new(y))
                cell = runtime.grid.get_grid(address)
                if cell.is_a?(IntegerPrimitive) || cell.is_a?(FloatPrimitive)
                    product += convert_to_num(cell).to_f
                    items += 1
                end
            end
        end
        FloatPrimitive.new((product / items).round(2))
    end

    def visit_sum(node, runtime)
        # no traversal needed, since topleft and btmright must be CellAddresses
        left = node.topleft
        right = node.btmright
        sum = 0
        (left.row.value..right.row.value).each do |x|
            (left.col.value..right.col.value).each do |y|
                address = CellAddressPrimitive.new(IntegerPrimitive.new(x), IntegerPrimitive.new(y))
                cell = runtime.grid.get_grid(address)
                if cell.is_a?(IntegerPrimitive) || cell.is_a?(FloatPrimitive)
                    # skip 0-valued or empty cells 
                    if cell.value != nil || cell.value != 0
                        sum += cell.value.to_f
                        # puts "accessing cell [#{x},#{y}]..."
                        # puts "#{cell.value} added to sum"
                    end
                end
            end
        end
        FloatPrimitive.new(sum.round(2))
    end

# ----------------------------------------------------------------------------------------------------
# VARIABLE REFERENCES AND LOOPS:  
# ----------------------------------------------------------------------------------------------------
    
    # evalute all statements in a block
    # save the evaluated result in some way
    # return the value produced from final statement
    def visit_block(node, runtime)
        results = []
        for statement in node.statements
            # puts "evaluating statement... #{statement}"
            results.append(statement.traverse(self, runtime))
        end
        return results[-1]
    end

    # look up and return associated primitive value stored in runtime
    def visit_variable_ref(node, runtime)
        #TODO: raise error if unknown variable
        raise TypeError "variable '#{node.variable}' is undefined" unless runtime.get_variable(node.variable) != nil
        # puts "#{runtime.get_variable(node.variable)}"
        return runtime.get_variable(node.variable)
    end

    # evaluate the right-hand side to a primitive and store 
    # the binding key-value store maintained in runtime
    def visit_assignment(node, runtime)
        var = node.right_node.traverse(self, runtime)
        # puts "`#{node.identifier.to_s}` assigned with value `#{var.value}`"
        runtime.set_variable(node.identifier, var)
    end

    # evaluate condition and choose which block to evaluate 
    def visit_conditional(node, runtime)
        condition = node.condition.traverse(self, runtime)
        # TODO: raise type error if condition does not parse down to boolean
        raise TypeError "condition must evaluate to a BOOLEAN" unless condition.is_a?(BooleanPrimitive)
        result = nil
        if condition
            result = node.if_block.traverse(self, runtime)
        else
            result = node.else_block.traverse(self, runtime)
        end
        return result
    end

    # iterate through the 2d window of cells and assign each cell's value to a local variable with the given name 
    # the block is evaluated for each cell in the given window.
    # the value returned is the result of the final iteration
    def visit_for_loop(node, runtime)
        iter = node.iter
        
    end

end
