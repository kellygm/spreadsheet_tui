# This class implements the visitor pattern to print a string representation
# of all the primitives and operations 

class Serializer 
# ----------------------------------------------------------------------------
# PRIMITIVES
# ----------------------------------------------------------------------------

    def visit_integer(node, payload)
        node.value.to_s 
    end
    
    def visit_float(node, payload)
        node.value.to_s 
    end

    def visit_bool(node, payload)
        node.value.to_s
    end

    def visit_string(node, payload)
        node.value.to_s  
    end

    def visit_celladdr(node, payload)
        "[#{node.row.traverse(self, payload)}, #{node.col.traverse(self, payload)}]"  
    end

    def visit_rvalue(node, payload)
        "#[#{node.row.traverse(self, payload)}, #{node.col.traverse(self, payload)}]"
    end

    def visit_lvalue(node, payload)
        "[#{node.row.traverse(self, payload)}, #{node.col.traverse(self, payload)}]"
    end
# ----------------------------------------------------------------------------
# ARITHMETIC 
# ----------------------------------------------------------------------------

    def visit_add(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} + #{right})"
    end

    def visit_sub(node, payload)
        left = node.left.traverse(self, payload) #traverse left
        right = node.right.traverse(self, payload) #traverse right
        "(#{left} - #{right})" #combine results
    end

    def visit_multiply(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} * #{right})"
    end

    def visit_divide(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} / #{right})"
    end

    def visit_modulo(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} % #{right})"
    end

    def visit_exp(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} ** #{right})"
    end

    def visit_negate(node, payload)
        value = node.value.traverse(self, payload)
        "-#{value}" 
    end

# ----------------------------------------------------------------------------
# RELATIONAL 
# ----------------------------------------------------------------------------

    def visit_equals(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} = #{b})"
    end

    def visit_not_equals(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} != #{b})"
    end

    def visit_less_than(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} < #{b})"
    end

    def visit_greater_than(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} > #{b})"
    end

    def visit_less_equals(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} <= #{b})"
    end

    def visit_greater_equals(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} >= #{b})"
    end

# ----------------------------------------------------------------------------
# STATISTICAL 
# ----------------------------------------------------------------------------

    def visit_max(node, payload)
        a = node.topleft.traverse(self, payload)
        b = node.btmright.traverse(self, payload)
        "max(#{a}, #{b})"
    end

    def visit_min(node, payload)
        a = node.topleft.traverse(self, payload)
        b = node.btmright.traverse(self, payload)
        "min(#{a}, #{b})"
    end

    def visit_mean(node, payload)
        a = node.topleft.traverse(self, payload)
        b = node.btmright.traverse(self, payload)
        "mean(#{a}, #{b})"
    end

    def visit_sum(node, payload)
        a = node.topleft.traverse(self, payload)
        b = node.btmright.traverse(self, payload)
        "sum(#{a}, #{b})"
    end

# ----------------------------------------------------------------------------
# LOGICAL
# ----------------------------------------------------------------------------

    def visit_log_and(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} && #{b})"
    end

    def visit_log_or(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} || #{b})"
    end

    def visit_log_not(node, payload)
        a = node.value.traverse(self, payload)
        "!#{a}"
    end
# ----------------------------------------------------------------------------
# BITWISE 
# ----------------------------------------------------------------------------

    def visit_bit_and(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} & #{b})"
    end

    def visit_bit_or(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} | #{b})"
    end

    def visit_bit_xor(node, payload)
        a = node.left.traverse(self, payload)
        b = node.right.traverse(self, payload)
        "(#{a} ^ #{b})"
    end

    def visit_bit_not(node, payload)
        a = node.value.traverse(self, payload)
        "~#{a}"
    end
    
    def visit_lshift(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} << #{right})"
    end

    def visit_rshift(node, payload)
        left = node.left.traverse(self, payload)
        right = node.right.traverse(self, payload)
        "(#{left} >> #{right})"
    end
# ----------------------------------------------------------------------------
# CASTING  
# ----------------------------------------------------------------------------
    def visit_float_to_int(node, payload)
        a = node.value.traverse(self, payload)
        "int(#{a})"
    end

    def visit_int_to_float(node, payload)
        a = node.value.traverse(self, payload)
        "float(#{a})"
    end
end