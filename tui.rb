require 'curses'
require 'logger'

require_relative 'primitive'
require_relative 'operation'
require_relative 'Evaluator'
require_relative 'serializer'
require_relative 'token'
require_relative 'lexer'
require_relative 'parser'
require_relative 'grid'
require_relative 'runtime'

include Curses

class TUI
    def initialize
        Curses::init_screen
        Curses::noecho
        Curses::use_default_colors
        Curses::curs_set(0)
        @grid = Runtime.new(Grid.new(12, 12)) # holds the evaluated value 
        @dependency_graph = Runtime.new(Grid.new(12, 12)) # holds the unevaulated source code of the values in grid
        # fill some of the cells 

    end

    # build the subwindows
    def build_windows
        subwin_width = Curses.cols / 2
        subwin_height = Curses.lines / 2

        @main_window = Curses.stdscr
        @main_window.keypad(true)

        @grid_win = @main_window.subwin(subwin_height + 2, subwin_width, 0, 0)
        @inst_panel = @main_window.subwin(subwin_height, subwin_width, subwin_height, 0)
        @display_panel = @main_window.subwin(subwin_height, subwin_width, 0, subwin_width)
        @formula_editor = @main_window.subwin(subwin_height, subwin_width, subwin_height, subwin_width)

        # add titles for the subwindows
        @display_panel.box("\u2502", "\u2500")
        @display_panel.setpos(1,1)
        @display_panel.addstr("DISPLAY PANEL")

        @formula_editor.box("\u2502", "\u2500")
        @formula_editor.setpos(1,1)
        @formula_editor.addstr("PRESSS 'e' TO ENTER EDIT MODE")

        # refresh windows to show changes
        @main_window.refresh
        @display_panel.refresh
        @grid_win.refresh
        @inst_panel.refresh
    end

    # split the grid subwindow into cells 
    def draw_grid
        subwin_width = Curses.cols / 2
        subwin_height = Curses.lines / 2
        @grid_win = @main_window.subwin(subwin_height, subwin_width, 0, 0)
        @grid_height = @grid_win.maxy - 2
        @grid_width = @grid_win.maxx - 2 # subtract 2 to give space for labels

        # define cell dimensions
        @cell_height =( @grid_height / 6)
        @cell_width = (@grid_width / 6)

        #label rows 0-5 (Y-axis)
        (0..5).each do |row|
            @grid_win.setpos((row * @cell_height) + 2, 0)
            @grid_win.addstr("#{row}")
        end

        #label cols 0-5 (X-axis)
        (0..5).each do |col|
            @grid_win.setpos(0, (col * @cell_width) + 8)
            @grid_win.addstr("#{col}")
        end

        # draw HORIZONTAL cell lines 
        (0..6).each do |row|
            @grid_win.setpos((row * @cell_height) + 1, 2)
            @grid_win.addstr("\u2500" * (@grid_width - 1))
        end
        
        # draw VERTICAL cell lines
        (0..6).each do |col|
            (1..6).each do |row|
                @grid_win.setpos((row * @cell_height), (col * @cell_width + 4))
                @grid_win.addstr("\u2502")
                @grid_win.setpos((row * @cell_height - 1), (col * @cell_width + 4))
                @grid_win.addstr("\u2502")
            end
        end

        # @grid_win.keypad(true)
        @grid_win.refresh
    end


    # fill some cells in the grid to start off (can be removed later, 
    # but it's nice to show how cells can be overwritten)
    def initialize_cells 
        addr1 = CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(0)) # [ 3 , 0 ]
        addr2 = CellAddressPrimitive.new(IntegerPrimitive.new(1), IntegerPrimitive.new(1)) # [ 1 , 1 ]
        addr3 = CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(3)) # [ 3 , 3 ]
        addr4 = CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(2)) # [ 3 , 2 ]
        addr5 = CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(1)) # [ 3 , 1 ]
        addr6 = CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(4)) # [ 3 , 4 ]
        addr7 = CellAddressPrimitive.new(IntegerPrimitive.new(3), IntegerPrimitive.new(5)) # [ 3 , 5 ]

        exp1 =  LessThan.new(Add.new(IntegerPrimitive.new(3), IntegerPrimitive.new(1)), IntegerPrimitive.new(10))
        exp2 = Modulo.new(Multiply.new(Add.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2)), IntegerPrimitive.new(3)), IntegerPrimitive.new(4))
        exp3 = Divide.new(FloatPrimitive.new(125.0), FloatPrimitive.new(7.85))
        exp4 = Divide.new(Add.new(FloatPrimitive.new(5.0), FloatPrimitive.new(6.0)), Multiply.new(FloatPrimitive.new(3.0), FloatPrimitive.new(2.0)))
        @grid.grid.set_grid(addr1, exp1) # "true" is saved at [3,0]      
        @grid.grid.set_grid(addr4, exp3) # "15.92" is saved at [3,2]
        @grid.grid.set_grid(addr3, StringPrimitive.new("pizza")) # "pizza" is saved at [3,3]
        @grid.grid.set_grid(addr7, exp4) # "1.83" is saved at [3,5]
        source_exp1 = Parser.new(Lexer.new("(3 + 1) < 10"))
        source_exp2 = Parser.new(Lexer.new("(5 + 2 * 3) % 4"))
        source_exp4 = Parser.new(Lexer.new("(5.0 + 6.0) / (3.0 * 2.0)"))
        @dependency_graph.grid.set_grid(addr1, "="+source_exp1.parse.traverse(Serializer.new, @dependency_graph))
        @dependency_graph.grid.set_grid(addr4, "="+source_exp2.parse.traverse(Serializer.new, @dependency_graph))
        @dependency_graph.grid.set_grid(addr3, "pizza")
        @dependency_graph.grid.set_grid(addr7, "="+source_exp4.parse.traverse(Serializer.new, @dependency_graph))

    end

    # fills grids with empty cells 
    def default_cells 
        (0..11).each do |col|
            (0..11).each do |row|
                cell = CellAddressPrimitive.new(IntegerPrimitive.new(col), IntegerPrimitive.new(row))
                @grid.grid.set_grid(cell, "")
                @dependency_graph.grid.set_grid(cell, "")
            end
        end
    end

    def run 
        @mode = :view # start app in view mode
        @subwin_row = 0
        @subwin_row = 0
        @current_col = 1
        @current_row = 1


        default_cells

        build_windows
        @inst_panel.setpos(1,1)
        @inst_panel.addstr("to switch to edit mode, press 'e'")
        @grid_win.clear
        draw_grid
        @grid_win.setpos(@current_row, @current_col)
        @grid_win.standout
        @formula_editor.refresh
        @display_panel.refresh
        
        # main interface process
        loop do
            # set the cursor to start at top-left cell of grid
            char = @main_window.getch
            case char
            when 'q'
                exit
                break
            when Curses::Key::UP, Curses::Key::DOWN, Curses::Key::LEFT, Curses::Key::RIGHT, 'j', 'k'
                @display_panel.clear
                handle_arrowkeys(char)
            when 'e'
                edit_mode
            end
        end
    end

    # handles cell highlighting and arrowkey behvaior while traversing the grid
    def handle_arrowkeys(char)
        @grid_win.refresh
        prev_row = @current_row
        prev_col = @current_col
        case char     
        when Curses::Key::UP
            @current_row -= 1 unless @current_row == 1 #restrict going outside of grid
        when Curses::Key::DOWN 
            @current_row += 1 unless @current_row == 6
        when Curses::Key::LEFT
            @current_col -= 1 unless @current_col == 1
        when Curses::Key::RIGHT
            @current_col += 1 unless @current_col == 6
        end
        
        update_display

        # empty the previous cell
        @grid_win.attroff(A_STANDOUT) # make sure starting cell isn't highlighted
        @grid_win.setpos((prev_row) * @cell_height, ((prev_col) * @cell_width))
        @grid_win.addstr(" " * (@cell_width / 2))

        # # Update the display window to show the current cell's unevaluated source
        # update_display
        # highlight the current cell
        @grid_win.attron( COLOR_GREEN | A_STANDOUT)
        @grid_win.setpos((@current_row) * @cell_height, (@current_col) * @cell_width)
        @grid_win.addstr(" " * (@cell_width / 2))
        @grid_win.attroff(COLOR_GREEN | A_STANDOUT)
        @grid_win.refresh

        # Update the cell position tracker 
        @grid_win.setpos(@grid_height + 1, 0)
        @grid_win.addstr("cell: [ #{@current_col - 1}, #{@current_row - 1} ]")
        @grid_win.refresh
    end

    def edit_mode
        # switch focus to start formula_editor
        @mode = :edit
        curs_set(1)
        x = @current_col
        y = @current_row
        # move the cursor into the formula editor
        @current_col = @formula_editor.begx + 2
        @current_row = @formula_editor.begy + 2
        @display_panel.clear
        # display the parsed version of current cell's content into the formula editor
        cell = CellAddressPrimitive.new(IntegerPrimitive.new(x), IntegerPrimitive.new(y))
        cell_value = @dependency_graph.grid.get_grid(cell)
        source_code = @dependency_graph.grid.get_grid(cell) || "" # default to empty string 
        text = source_code.to_s
        # Display the source code in the formula editor
        @formula_editor.clear
        @formula_editor.setpos(1,1)
        @formula_editor.addstr("FORMULA EDITOR: EDIT MODE")
        @formula_editor.box("\u2502", "\u2500")
        @formula_editor.setpos(2, 4)
        @formula_editor.addstr(text)

        # loop while tracking char input
        loop do 
            @formula_editor.clear
            @formula_editor.setpos(1,1)
            @formula_editor.addstr("FORMULA EDITOR: EDIT MODE")
            @formula_editor.box("\u2502", "\u2500")
            @formula_editor.setpos(2, 4)
            @formula_editor.addstr(text)
            # keep track of the edits user makes to input 
            ch = @formula_editor.getch
                case ch 
                when 'q'
                    @formula_editor.clear
                    @current_col = x 
                    @current_row = y
                    break
                when Curses::Key::BACKSPACE, "\b", 8, '\177'
                    text.chop! # remove last char from text
                when Curses::Key::ENTER, "\r", 10 # triggers new value update
                    # parse the user-entered data when needed
                    new_value = text
                    edit_cells(x, y, new_value)
                    update_display
                    # update_editor
                    @mode = :view                    
                    @current_col = x
                    @current_row = y
                    @formula_editor.refresh
                    @display_panel.refresh
                    break
                else 
                    text += ch.to_s # add character to exisiting string
                    @formula_editor.addstr(ch.to_s)
                end
            end
        # update cell and display panel accordingly
        update_display

    end

    # update the cell's values at the current position 
    # when the user is in editor mode on the formula_editor 
    # update the dependency graph to hold the cell's unevaluated source code
    def edit_cells(x, y, new_value)
        cell = CellAddressPrimitive.new(IntegerPrimitive.new(x - 1), IntegerPrimitive.new(y - 1))
        # check if input is an expression that needs to be parsed and lexed ( i.e. starts with '=' )
        if new_value.start_with?("=")
            begin 
                expression = Parser.new(Lexer.new(new_value[1..-1]))
                parsed_exp = expression.parse
                puts "Parsed Expression: #{parsed_exp.inspect}\n"  # Debugging parsing
                evaluated_exp = parsed_exp.traverse(Evaluator.new, @grid).traverse(Serializer.new, @grid) # took 3 hours to realize that Evaluator was spelt wrong...
                puts "Evaluated Result: #{evaluated_exp.inspect}\n"  # Debugging evaluation
                @grid.grid.set_grid(cell, evaluated_exp.to_s)
                @dependency_graph.grid.set_grid(cell, "="+new_value[1..-1])
            rescue => err 
                @grid.grid.set_grid(cell, err.message.to_s)
                @dependency_graph.grid.set_grid(cell, new_value.to_s)
            end
        else 
            # determine if values can be converted to int or float, otherwise save them as string primitives
            case new_value.downcase
            when /^-?\d+\.\d+$/ # match decimal numbers 
               value =  FloatPrimitive.new(new_value.to_f)
            when /^-?\d+$/ # match integers 
                value = IntegerPrimitive.new(new_value.to_i)
            when "true", "false" # boolean values 
                value = BooleanPrimitive.new(new_value == "true")
            else 
                value = StringPrimitive.new(new_value)
            end
            @grid.grid.set_grid(cell, value) # save evaluted expression (for Edit Mode)
            @dependency_graph.grid.set_grid(cell, value.to_s) # save unevaluted expression (for Display Panel)
        end         
        
    end

    # read the cell content of the currently selected cell and display its 
    # unevaluated and evaluted expressions in the appropriate windows
    def update_display()
        # @display_panel.clear
        (1..6).each do |col|
            (1..6).each do |row|
                @display_panel.clear
                @display_panel.setpos(1,1)
                @display_panel.addstr("DISPLAY PANEL")
                @display_panel.box("\u2502", "\u2500")
                @display_panel.setpos(3, 4) # Adjust the position based on the current row
                @formula_editor.clear
                @formula_editor.setpos(1,1)
                @formula_editor.addstr("Press 'e' to enter EDIT MODE")
                @formula_editor.box("\u2502", "\u2500")
                @formula_editor.setpos(3, 4)
                # pass the current grid position as a cell addr primitive 
                # need to subtract 1 to avoid counting row and column labels as part of grid
                cell = CellAddressPrimitive.new(IntegerPrimitive.new(col - 1), IntegerPrimitive.new(row - 1))
                cell_value = @grid.grid.get_grid(cell)

                # use that cell to search the two grids for their evaluted and unevaluted values 
                source_code = @dependency_graph.grid.get_grid(cell)
                if source_code.start_with?("=")
                    begin
                        expression = Parser.new(Lexer.new(source_code[1..-1])).parse
                        evaluated_exp = expression.traverse(Evaluator.new, @grid).traverse(Serializer.new, @grid)
                        @display_panel.addstr(evaluated_exp.to_s)
                    rescue TypeError => err
                        @display_panel.addstr("ERROR: #{err.message}")
                    end
                # display the source code in the display panel
                elsif cell_value.is_a?(Primitive)
                    unevaluated = cell_value.traverse(Serializer.new, @grid) 
                    @display_panel.addstr(unevaluated.to_s)
                else 
                    @display_panel.addstr(" ")
                end
                
                # update the corresponding grid based on the value entered in cells
                dependency_val = @dependency_graph.grid.get_grid(cell)
                if dependency_val.is_a?(String)
                    @formula_editor.addstr(dependency_val)
                else
                    @formula_editor.addstr(" ")
                end
                if (col == @current_col && row == @current_row)
                    @display_panel.refresh
                    @formula_editor.refresh
                end
                
            end
        end
    end




end


begin
    tui = TUI.new
    tui.run
ensure close_screen
end