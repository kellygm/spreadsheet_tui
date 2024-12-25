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
``` primitive.rb ``` <br>
``` operation.rb ```<br>
``` evaluator.rb ```<br>
``` serializer.rb ```<br>
``` grid.rb ``` <br>

### Milestone 2 ###
Files:<br>
``` grammar.txt ```<br>
``` lexer.rb ``` <br>
``` parser.rb ```<br>
``` token.rb ```<br>

### Milestone 3 ###
Files: <br>
``` tui.rb ```


**I am currently expanding on this project so that it supports the following:**
- conditionals
- loops
- function calls
