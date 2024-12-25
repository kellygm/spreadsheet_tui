# Grid Kid - Spreadsheet Program
This semester-long project is a terminal user interface of a spreadsheet. Like other spreadsheet programs, this one presents a table of cells that the user fills with data and formulae to achieve various computational tasks. Users will enter into cells either code or plain text data. The code may contain cell references, variable references, multiple statements.

This project was broken down into various subprojects (called "milestones").
<ul>
<li>Milestone 1: Model: develop the model for the spreadsheet, which is a set of abstractions representing a 2-dimensional grid of cells and formulas, literal values that can go into cells. </li>
<li>Milestone 2: Interpreter: Develop an interpreter for the spreadsheet that translates arbitrary source code from the spreadsheet programmer into the model classes from milestone 1.</li>
<li>Milestone 3: Interface: Design a terminal-based user interface for the spreadsheet using the Curses library. The interface allows users to move around to different cells using the cursor keys,enter formula, and view the results. </li>
</ul>


### Milestone 1 ###
Files:<br>
``` primitive.rb ``` - define expression structure for floats, integers, booleans, strings, and cell addresses <br>
``` operation.rb ``` - defines the operations supported in the spreadsheet <br>
``` evaluator.rb ``` - a visitor that evalutes an abstract syntax tree. Each node in the expression hierachy must evaluate to one of the primitive abstractions <br>
``` serializer.rb ``` - string representation of expressions <br>
``` grid.rb ``` - a grid abstraction that manages all the cells <br>

### Milestone 2 ###
Files:<br>
``` grammar.txt ``` - grammar for the spreadsheet's expression syntax in EBNF syntax <br>
``` lexer.rb ``` - lexer abstraction that accepts an expression in text form and tokenizes it into a list of tokens <br>
``` parser.rb ``` - parser abstraction that accepts a list of tokens and assembles an abstract syntax tree using the model abstractions from milestone 1<br>
``` token.rb ``` - token abstraction for tracking supported expressions in the source code, and producing useful error messages <br>

### Milestone 3 ###
Files: <br>
``` tui.rb ``` - terminal based user interface for the spreadsheet.
<br>
Supported Functionality:
- user selects cells by moving around with the arrow keys. selection is highlighted<br>
- when user selects a cells, its unevaluted source is displayed in the formula editor, its primitive value is shown in the display panel<br>
- when the user hits the 'e' key in 'view mode', focus is moved to the editor, and the user may type in new text or delete old text <br>
- hitting 'e' again will return focus to the grid, and the cell and display panel will upate and show the new value or resulting error message.<br>
- any other cells that depend on the modified cell via rvalue or cell lvalue also update<br>
- if text starts with an ```=``` its treated as source code, otherwise it is an integer, float, or boolean and treated as a primitive in the expression hierarchy.<br>
- all other input is treated as a plain string<br>
<br>

**I am currently expanding on this project so that it supports the following:**
- conditionals
- loops
- function calls
