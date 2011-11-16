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
    find_man
    cls
    print_board

    catch :quit do
      loop do
        move (read_char.chr.downcase)
      end
    end

    puts "Thanks for playing. Come back soon! :)"
  end

  private

  def man
    '@'
  end

  def box
    'o'
  end

  def wall
    '#'
  end

  def storage
    '.'
  end

  def storage_with_man
    '+'
  end

  def storage_with_box
    '*'
  end

  def space
    ' '
  end

  def read_level
    open @levels_filename do |file|
      file.each do |line|
        @board << line.chars.to_a
      end
    end
  end

  def find_man
    @board.each_with_index do |line, index|
      if line.include?(man)
        @x = index
        @y = line.index man
      end
    end
  end

  def print_board
    puts @board.map(&:join)
  end

  # This method is not being used in the program, but it's good to have
  def in_board?(x, y)
    x >= 0 && y >= 0 && x < @board.size && y < @board[x].size - 1
  end

  def won?
    @board.none? do |line|
      line.any? { |p| p == box }
    end
  end

  def move_box(x, y)
    @board[x][y] = case object_at x, y
    when space
      box
    when storage
      storage_with_box
    end
  end

  def move_man(x, y)
    # draw man at new position
    @board[x][y] = case object_at x, y
    when space, box
      man
    when storage, storage_with_box
      storage_with_man
    end

    # clear man from previous position
    @board[@x][@y] = object_at(@x, @y) == man ? space : storage

    # chage man to new position
    @x, @y = x, y
  end

  def object_at(x, y)
    @board[x][y]
  end

  def move(command)
    x1, y1, x2, y2 = case command
    when 'w'
      [@x - 1, @y, @x - 2, @y]
    when 's'
      [@x + 1, @y, @x + 2, @y]
    when 'a'
      [@x, @y - 1, @x, @y - 2]
    when 'd'
      [@x, @y + 1, @x, @y + 2]
    when 'q'
      throw :quit
    else
      puts "Invalid command" && return
    end

    case object_at x1, y1
    when wall
    when space, storage
      move_man x1, y1
    when box, storage_with_box
      case object_at x2, y2
      when space, storage
        move_box x2, y2
        move_man x1, y1
      end
    end

    cls
    print_board

    if won?
      puts "WIN :)"
      throw :quit
    end
  end
end

Sokoban.new("levels.txt").play