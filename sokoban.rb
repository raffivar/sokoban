begin
  require 'Win32API'

  def cls
    system 'cls'
  end

  def read_char
    require "Win32API"
    Win32API.new("crtdll", "_getch", [], "L").Call
  end
rescue LoadError
  def cls
    system 'clear'
  end

  def read_char
    begin
      system "stty raw -echo"
      str = STDIN.getc
    ensure
      system "stty -raw echo"
    end
    str.chr
  end
end

class Sokoban
  def initialize(levels_filename)
    @levels_filename = levels_filename
    @board = []
    @x = -1
    @y = -1
  end

  def play
    read_level
    cls
    print_board

    begin
      command = read_char.downcase
      move command
    end while command != 'q' && check_for_win == false

    puts "Thanks for playing. come back soon! :)"
  end

  private

  def read_level
    ######## SAVE LEVEL STATE INTO "$board" ########
    open "levels.txt" do |file|
      line = []
      while char = file.getc
        if char != "\n"
          if char == "@"
            @x = @board.size
            @y = line.size
          end
          line << char
        else
          line << char
          @board << line
          line = []
        end
      end
      #end of file is not "\n", but still need to insert the line into the board
      line << "\n"
      @board << line
    end
  end

  def print_board
    @board.each do |line|
      line.each do |char|
        print char
      end
    end
  end

  #This function is not being used in the program, but it's good to have
  def in_board?(x, y)
    if x >= 0 && y >=0 && x < @board.size && y < @board[x].size - 1
      true
    else
      false
    end
  end

  def check_for_win
    @board.each do |line|
      line.each do |char|
        if char == 'o'
          return false
        end
      end
    end
    puts "WIN :)"
    return true
  end

  def move_box(x, y)
    case @board[x][y]
    when " "  #move box to free space
      @board[x][y] = "o"
    when "."  #move box to storage spot
      @board[x][y] = "*"
    end
  end

  def move_man(x, y)
    #draw man at new position
    if @board[x][y] == " " || @board[x][y] == "o"
      @board[x][y] = "@"
    elsif @board[x][y] == "." || @board[x][y] == "*"
      @board[x][y] = "+"
    end

    #clear man from previous position
    if @board[@x][@y] == "@"
      @board[@x][@y] = " "
    else
      @board[@x][@y] = "."
    end

    #chage man to new position
    @x = x
    @y = y
  end

  def move(command)
    valid_command = true

    case command
    when 'w'
      x1 = @x - 1
      y1 = @y
      x2 = @x - 2
      y2 = @y
    when 's'
      x1 = @x + 1
      y1 = @y
      x2 = @x + 2
      y2 = @y
    when 'a'
      x1 = @x
      y1 = @y - 1
      x2 = @x
      y2 = @y - 2
    when 'd'
      x1 = @x
      y1 = @y + 1
      x2 = @x
      y2 = @y + 2
    else
      valid_command = false
    end

    if valid_command
      if @board[x1][y1] != "#"  #if the spot near isn't a wall
        case @board[x1][y1]
        when " ", "." #if the spot near the man is free, go there
          move_man x1, y1
        when "o", "*" #if the spot near the man is not free, check the next spot
          case @board[x2][y2]
          when " ", "." #if the next spot is free
            move_box x2, y2
            move_man x1, y1
          end
        end
      end

      cls
      print_board
    else
      abort "Invalid command"
    end
  end
end

Sokoban.new("levels.txt").play
