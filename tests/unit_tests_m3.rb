# Tests for Milestone 4: Variables and Flow 
require_relative '../parser'
require_relative '../lexer'
require_relative '../runtime'
require_relative '../serializer'
require_relative '../primitive'
require_relative '../operation'
require_relative '../grid'
require_relative '../runtime'
require_relative '../evaluator'


# Variable Declarations and References
runtime = Runtime.new(Grid.new(6,6))


exp1 = Modulo.new(Add.new(Multiply.new(IntegerPrimitive.new(7), IntegerPrimitive.new(4)), IntegerPrimitive.new(3)), IntegerPrimitive.new(12) ) # --> '7'
rval1 = CellRValue.new(IntegerPrimitive.new(3), IntegerPrimitive.new(1))
rval2 = CellRValue.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1))
runtime.grid.set_grid(rval1, IntegerPrimitive.new(10))
runtime.grid.set_grid(rval2, IntegerPrimitive.new(2))
val1 = exp1.traverse(Evaluator.new, runtime)

exp2 = Multiply.new(rval1, Negation.new(rval2))
val2 = exp2.traverse(Evaluator.new, runtime)
exp3 = LogicNot.new(GreaterThan.new(FloatPrimitive.new(3.3), FloatPrimitive.new(3.2)))
val3 = exp3.traverse(Evaluator.new, runtime)

exp4 = Negation.new(FloatPrimitive.new(3.1))
val4 = exp4.traverse(Evaluator.new, runtime)


runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(1))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(1)), IntegerPrimitive.new(3))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(2)), FloatPrimitive.new(3.05))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(3)), BooleanPrimitive.new(true))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(4)), IntegerPrimitive.new(2.0))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(5)), FloatPrimitive.new(18883.01))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(6)), Negation.new(IntegerPrimitive.new(3)).traverse(Evaluator.new, runtime))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0)), IntegerPrimitive.new(10))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), val3)
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(6)), FloatPrimitive.new(2.33))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1)), FloatPrimitive.new(0.5))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(0)), val1)
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(6)), val4)
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(4), IntegerPrimitive.new(1)), IntegerPrimitive.new(2.0))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2)), IntegerPrimitive.new(2.0))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(5)), val2)


puts "Grid was initialized with the following cell values..."
puts "[0,0] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0))).value}"
puts "[0,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(1))).value}"
puts "[0,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(2))).value}"
puts "[0,3] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(3))).value}"
puts "[0,4] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(4))).value}"
puts "[0,5] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(5))).value}"
puts "[0,6] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(6))).value}"
puts "[1,0] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0))).value}"
puts "[1,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1))).value}"
puts "[1,6] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(6))).value}"
puts "[2,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1))).value}"
puts "[3,0] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(0))).value}"
puts "[3,6] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(6))).value}"
puts "[4,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(4), IntegerPrimitive.new(1))).value}"
puts "[5,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2))).value}"
puts "[5,5] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(5))).value}"


prop = Assignment.new("proportion", Add.new(IntegerPrimitive.new(3), IntegerPrimitive.new(5)))
# prop.traverse(Evaluator.new, runtime)
amount = Assignment.new("amount", Sum.new(CellRValue.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1)), CellRValue.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2))))
# amount.traverse(Evaluator.new, runtime)

block = Block.new()
block.add_statement(prop)
block.add_statement(amount)
block.add_statement(Multiply.new(VariableReference.new(prop.identifier), VariableReference.new(amount.identifier)))
puts "BLOCK evalutes to... #{block.traverse(Evaluator.new, runtime).value}"

runtime.print_vars

if_block = Block.new()
if_block.add_statement(IntegerPrimitive.new(1))
else_block = Block.new()
else_block.add_statement(IntegerPrimitive.new(0))
if_else = Conditional.new(GreaterThan.new(CellRValue.new(IntegerPrimitive.new(4), IntegerPrimitive.new(1)), CellRValue.new(IntegerPrimitive.new(5), IntegerPrimitive.new(5))), if_block, else_block)

puts "#{if_else.traverse(Serializer.new, runtime)}"


block = Block.new()
block.add_statement(Assignment.new("count", IntegerPrimitive.new(0)))
for_block = Block.new()
for_block.add_statement(Assignment.new("count", Add.new(VariableReference.new("count"), IntegerPrimitive.new(1))))
for_each = ForLoop.new("value", CellLValue.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), CellLValue.new(IntegerPrimitive.new(0), IntegerPrimitive.new(6)), for_block)
block.add_statement(for_each)

# puts "#{block.traverse(Evaluator.new, runtime).value}"