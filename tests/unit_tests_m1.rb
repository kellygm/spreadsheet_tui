require_relative '../Serializer'
require_relative '../Evaluator'
require_relative '../Primitive'
require_relative '../Runtime'
require_relative '../Grid'
require_relative '../Operation'


# Tests to demonstrate grid serializing and evaluting
runtime = Runtime.new(Grid.new(6,6))
# ------------------------------------------------------------------------------------------
# Fill grid with lots of values for more accurate testing
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2)), IntegerPrimitive.new(5))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(2)), IntegerPrimitive.new(12) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(2)), FloatPrimitive.new(2.2) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(4), IntegerPrimitive.new(2)), IntegerPrimitive.new(3) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2)), FloatPrimitive.new(1.2) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(3)), IntegerPrimitive.new(5) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(3)), IntegerPrimitive.new(14) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(3)), IntegerPrimitive.new(100) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(4), IntegerPrimitive.new(3)), IntegerPrimitive.new(7) )
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3)), IntegerPrimitive.new(11) )
# ------------------------------------------------------------------------------------------


# Arithmetic: (7 * 4 + 3) % 12 -> "7"
exp1 = Modulo.new(Add.new(Multiply.new(IntegerPrimitive.new(7), IntegerPrimitive.new(4)), IntegerPrimitive.new(3)), IntegerPrimitive.new(12) )
puts exp1.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp1.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}" 
puts

# Arithmetic negation and cell rvalues: #[3, 1] * -#[2, 1] -> "-20"
rval1 = CellRValue.new(IntegerPrimitive.new(3), IntegerPrimitive.new(1))
rval2 = CellRValue.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1))
runtime.grid.set_grid(rval1, IntegerPrimitive.new(10))
runtime.grid.set_grid(rval2, IntegerPrimitive.new(2))
puts "the value at cell [3,1] is... #{runtime.grid.get_grid(rval1).value}"
puts "the value at cell [2,1] is... #{runtime.grid.get_grid(rval2).value}"

exp2 = Multiply.new(rval1, Negation.new(rval2))
puts exp2.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp2.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}" 
puts

# Rvalue lookup and shift: #[1 + 1, 4] << 3 --> "16"
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(4)), IntegerPrimitive.new(2))
puts "the value at cell [2,4] is... #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(4))).value}"
exp3 = LeftShift.new(CellRValue.new(Add.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), IntegerPrimitive.new(4)), IntegerPrimitive.new(3))

shift_result = exp3.traverse(Evaluator.new, runtime)
puts "#[1 + 1, 4] << 3 evaluates to... #{shift_result.traverse(Serializer.new, runtime)}"
puts

# Rvalue lookup and comparison: #[0, 0] < #[0, 1] --> "true"
addr1 = CellRValue.new(IntegerPrimitive.new(0),IntegerPrimitive.new(0))
addr2 = CellRValue.new(IntegerPrimitive.new(0),IntegerPrimitive.new(1))
runtime.grid.set_grid(addr1, IntegerPrimitive.new(5))
runtime.grid.set_grid(addr2, IntegerPrimitive.new(8))
p1 = runtime.grid.get_grid(addr1)
p2 = runtime.grid.get_grid(addr2)
exp4 = LessThan.new(p1, p2)
puts exp4.traverse(Serializer.new, runtime) + "     Evalutes to: #{exp4.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Logic and comparison: !(3.3 > 3.2) --> "false"
exp5 = LogicNot.new(GreaterThan.new(FloatPrimitive.new(3.3), FloatPrimitive.new(3.2)))
puts exp5.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp5.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}" 
puts

# Sum: sum([1, 2], [5, 3]) --> "160.4"
puts "Grid was initialized with the following cell values..."
puts "[1,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2))).value}"
puts "[2,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(2))).value}"
puts "[3,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(2))).value}"
puts "[4,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(4), IntegerPrimitive.new(2))).value}"
puts "[5,2] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2))).value}" 
puts "[1,3] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(3))).value}"
puts "[2,3] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(3))).value}"
puts "[3,3] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(3))).value}"
puts "[4,3] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(4), IntegerPrimitive.new(3))).value}"
puts "[5,3] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))).value}"

exp6 = Sum.new(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2)), CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3)))
puts exp6.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp6.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}" 
puts

# Mean: mean([1, 2], [5, 3]) --> "16.4"
exp7 = Mean.new(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2)), CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3)))


# Min: min([1, 2], [5, 3]) --> "1.2"
exp8 = Min.new(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2)), CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3)))

# Max: max([1, 2], [5, 3]) --> "100"
exp9 = Max.new(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2)), CellAddressPrimitive.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3)))


# Casting: float(7) / 2 --> "3.5"
exp10 = Divide.new(IntToFloat.new(IntegerPrimitive.new(7)), IntegerPrimitive.new(2))
puts exp10.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp10.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Make sure that the expressions work for m2 before moving on

# Rvalue lookup and comparison: #[1 - 1, 0] < #[1 * 1, 1] -> should be "false"
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), IntegerPrimitive.new(5)) # [1,1] = 10
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(10)) # [0,0] = 5
left = CellRValue.new(Subtract.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), IntegerPrimitive.new(0))
right = CellRValue.new(Multiply.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), IntegerPrimitive.new(1))

exp11 = LessThan.new(left, right)
puts exp11.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp11.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Logic and comparison: (5 > 3) && !(2 > 8) --> should be 'true'
left = GreaterThan.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3)) # --> should be "true"
right = LogicNot.new(GreaterThan.new(IntegerPrimitive.new(2), IntegerPrimitive.new(8))) # --> should be "true"

exp12 = LogicAnd.new(left, right);
puts exp12.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp12.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Rvalue lookup and shift: #[0, 0] + 3 --> should be '13'
exp13 = Add.new(CellRValue.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(3))
puts "value at cell [0,0] is ... #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0))).traverse(Serializer.new, runtime)}"
puts exp13.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp13.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Sum: 1 + sum([0, 0], [2, 1]) --> should be '26.0'
right = Sum.new(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1)))
exp14 = Add.new(IntegerPrimitive.new(1), right)
puts exp14.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp14.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Casting: float(10) / 4.0 --> should be '2.5'
exp15 = Divide.new(IntToFloat.new(IntegerPrimitive.new(10)), FloatPrimitive.new(4.0))
puts exp15.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp15.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Arithmetic: (5 + 2) * 3 % 4 --> should be '1'
left = Multiply.new(Add.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2)), IntegerPrimitive.new(3))
exp16 = Modulo.new(left, IntegerPrimitive.new(4))
puts exp16.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp16.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts


# Rvalue lookup and Left shift: [0,0] << 3 --> should parse to '24'
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(3))
exp17 = LeftShift.new(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(3))
puts exp17.traverse(Serializer.new, runtime) + "\t Evalutes to: #{exp17.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts