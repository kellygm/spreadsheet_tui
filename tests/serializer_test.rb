require_relative '../Serializer'
require_relative '../Evaluator'
require_relative '../Primitive'
require_relative '../Runtime'
require_relative '../Grid'
require_relative '../Operation'

# Tests after Milestone I changes 
runtime = Runtime.new(Grid.new(6,6))
exp1 = Modulo.new(Multiply.new(IntegerPrimitive.new(7), Add.new(IntegerPrimitive.new(4), IntegerPrimitive.new(3))), IntegerPrimitive.new(12))
puts exp1.traverse(Serializer.new, runtime)
