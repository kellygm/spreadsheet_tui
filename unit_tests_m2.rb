require_relative 'Parser'
require_relative 'Lexer'
require_relative 'Runtime'
require_relative 'Serializer'

# Tests for Parser and Lexer 

# Lexer tests are commented out for output neatness, uncommenting them
# will show all tokens were properly spotted

# Set up test grid
runtime = Runtime.new(Grid.new(6,6))


#Arithmetic: (5 + 2) * 3 % 4 -> should parse to '1'
exp1 = "(5 + 2) * 3 % 4"

lex = Lexer.new(exp1)
result = lex.print_tokens
parser = Parser.new(lex)
puts "(5 + 2) * 3 % 4 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

#Rvalue lookup and comparison: #[1 - 1, 0] < #[1 * 1, 1] -> should parse to 'false'
exp3 = "[1 - 1, 0] < #[1 * 1, 1]"
addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0))
addr2 = CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1))
runtime.grid.set_grid(addr1, IntegerPrimitive.new(1))
runtime.grid.set_grid(addr2, IntegerPrimitive.new(0))

lexer = Lexer.new(exp3)
parser = Parser.new(lexer)

puts "[1 - 1, 0] < #[1 * 1, 1] PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

#Logic and comparison: (5 > 3) && !(2 > 8) --> should parse to 'true'
exp4 = "(5 > 3) && !(2 > 8)"
lexer = Lexer.new(exp4)
parser = Parser.new(lexer)

puts "(5 > 3) && !(2 > 8) PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

#Sum: 1 + sum([0, 0], [2, 1]) --> should be '19.3'
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(1))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(1)), IntegerPrimitive.new(3))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0)), IntegerPrimitive.new(10))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), IntegerPrimitive.new(2.3))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1)), IntegerPrimitive.new(2.0))


exp5 = "1 + sum([0, 0], [2, 1])"
puts "Grid was initialized with the following cell values..."
puts "[0,0] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0))).value}"
puts "[0,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(1))).value}"
puts "[1,0] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0))).value}"
puts "[1,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1))).value}"
puts "[2,1] --> #{runtime.grid.get_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1))).value}"
lexer = Lexer.new(exp5)
parser = Parser.new(lexer)

puts "1 + sum([0, 0], [2, 1]) PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

#Casting: float(10) / 4.0 --> should parse to '2.5'
exp6 = "float(10) / 4.0"
lexer = Lexer.new(exp6)
parser = Parser.new(lexer)

puts "float(10) / 4.0 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts


# Rvalue lookup and Left shift: [0,0] << 3 --> should parse to '24'
exp7 = "[0,0] << 3"
runtime.grid.set_grid(addr1, IntegerPrimitive.new(3))
lexer = Lexer.new(exp7)
parser = Parser.new(lexer)
puts "value at cell [0,0] is... #{runtime.grid.get_grid(addr1).traverse(Serializer.new, runtime)}"

puts "[0,0] << 3 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Rvalue lookup and Right shift: [0,0] >> 3 --> should parse to '10'
exp8 = "[0,0] >> 3"
runtime.grid.set_grid(addr1, IntegerPrimitive.new(80))
lexer = Lexer.new(exp8)
parser = Parser.new(lexer)
puts "value at cell [0,0] is... #{runtime.grid.get_grid(addr1).traverse(Serializer.new, runtime)}"

puts "[0,0] >> 3 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Casting: Casting: float(10) / 4.0 --> should be '2.5'
exp9 = "float(10) / 4.0"
lexer = Lexer.new(exp9)
parser = Parser.new(lexer)
puts "float(10) / 4.0 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Exponentiation: 2 ** 3 ** 2 --> should be '64'
exp10 = "2 ** 3 ** 2"
lexer = Lexer.new(exp10)
parser = Parser.new(lexer)
puts "2 ** 3 ** 2 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Negation and bitwise and: 45 & ---(1 + 3) -> should be '44'
exp11 = "45 & ---(1 + 3)"
lexer = Lexer.new(exp11)
parser = Parser.new(lexer)
puts "45 & ---(1 + 3) PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# --- Additional Tests --- 

#Rvalue lookup and sum: #[0, 0] + 3 -> should parse to '6'
addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0))
runtime.grid.set_grid(addr1, IntegerPrimitive.new(3))
exp2 = "[0, 0] + 3"

lexer = Lexer.new(exp2)
parser = Parser.new(lexer)
puts "[0, 0] + 3 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Max and Comparison: max([0,0], [2,1]) < 5 --> should be 'false'
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(0)), IntegerPrimitive.new(1))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(1)), IntegerPrimitive.new(3))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0)), IntegerPrimitive.new(10))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)), IntegerPrimitive.new(2.3))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(0)), IntegerPrimitive.new(3.33333))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(1)), IntegerPrimitive.new(2.0))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(2), IntegerPrimitive.new(2)), BooleanPrimitive.new(true))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(2)), StringPrimitive.new("teenage mutant ninja turtles"))
runtime.grid.set_grid(CellAddressPrimitive.new(IntegerPrimitive.new(0), IntegerPrimitive.new(2)), StringPrimitive.new("***turtle power****"))

exp12 = "max([0,0], [2,1]) < 5"
lexer = Lexer.new(exp12)
parser = Parser.new(lexer)
puts "max([0,0], [2,1]) PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts 

# Min lookup: max([0,0], [2,1]) --> should be '1.0'
exp13 = "min([0,0], [2,1])"
lexer = Lexer.new(exp13)
parser = Parser.new(lexer)
puts "min([0,0], [2,1]) PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts 

# Mean lookup: mean([0,0], [2,1]) --> should be '3.605555' or '3.61'
exp14 = "mean([0,0], [2,2])"
lexer = Lexer.new(exp14)
parser = Parser.new(lexer)
puts "mean([0,0], [2,1]) PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Multiply and XOR: (1 + 2) * (3 + 4) ^ 2 --> should be '23'
exp15 = "(1 + 2) * (3 + 4) ^ 2"
lexer = Lexer.new(exp15)
parser = Parser.new(lexer)
puts "(1 + 2) * (3 + 4) ^ 2 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

# Comparison Combination: (1+2) < 4 && (3 ** 1) >= 0
exp16 = "(1+2) < 4 && (3 ** 1) >= 0"
lexer = Lexer.new(exp16)
parser = Parser.new(lexer)
puts "(1+2) < 4 && (3 ** 1) >= 0 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts

exp17 = "~6 - 3"
lexer = Lexer.new(exp17)
parser = Parser.new(lexer)
puts "~6 - 3 PARSED to... #{parser.parse.traverse(Evaluator.new, runtime).traverse(Serializer.new, runtime)}"
puts