class Piece
  attr_accessor :path, :color, :position_x, :position_y
  def initialize (color = 'white', x = 0, y = 0)
    @path = []
    @color = color
    @position_x = x
    @position_y = y
  end

  def update_position(x, y)
    @position_x = x
    @position_y = y
  end

  def find_path(destination)
    result = []
    m, n = destination
    x, y = @position_x, @position_y
    if (m - x).abs * (n - y).abs == 2  # knight move
      return result
    elsif m == x
      for i in 0..7
        result << [m , i] if (n - i) * (y - i) < 0
      end
      return result
    elsif n == y 
      for i in 0..7
        result << [i , n] if (m - i) * (x - i) < 0
      end
      return result
    elsif (m - x).abs == (n - y).abs
      d1 = m - x > 0 ? 1 : -1
      d2 = n - y > 0 ? 1 : -1
      tem_x, tem_y = x + d1, y + d2
      while tem_x != m && tem_y != n
        result << [tem_x, tem_y]
        tem_x += d1
        tem_y += d2
      end
      return result
    end
  end
end

class King < Piece
  attr_accessor :been_moved, :unicode
  def initialize(color = 'white', x = 0, y = 0, unicode = "\u265A")
    super(color, x, y)
    @been_moved = false
    @unicode = unicode
  end

  def valid_move?(destination)
    m, n = destination
    return false unless m.between?(0, 7) && n.between?(0, 7) && !(m == @position_x && n == @position_y)
    return false if (@position_x - m).abs != 1 && (@position_y - n).abs != 1
    return true
  end
end

class Queen < Piece
  attr_accessor :unicode
  def initialize (color = 'white', x = 0, y = 0, unicode)
    super(color, x, y)    
    @unicode = unicode
  end
  def valid_move?(destination)
    m, n = destination
    return false unless m.between?(0, 7) && n.between?(0, 7) && !(m == @position_x && n == @position_y)
    if m == @position_x || n == @position_y || (m - @position_x).abs == (n - @position_y).abs
      @path = find_path(destination)
      return true
    else 
      return false
    end    
  end
end

class Rook < Piece
  attr_accessor :been_moved, :unicode
  def initialize (color = 'white', x = 0, y = 0, unicode)
    super(color, x, y)
    @been_moved = false
    @unicode = unicode
  end
  def valid_move?(destination)
    m, n = destination
    return false unless m.between?(0, 7) && n.between?(0, 7) && !(m == @position_x && n == @position_y)
    if m == @position_x || n == @position_y
      @path = find_path(destination)
      return true
    else 
      return false
    end  
  end
end

class Knight < Piece
  attr_accessor :unicode
  def initialize (color = 'white', x = 0, y = 0, unicode)
    super(color, x, y)
    @unicode = unicode
  end
  def valid_move?(destination)
    m, n = destination
    return false unless m.between?(0, 7) && n.between?(0, 7) && !(m == @position_x && n == @position_y)
    if ((m - @position_x) * (n - @position_y)).abs == 2
      @path = find_path(destination)
      return true
    else 
      return false
    end  
  end
end

class Bishop < Piece
  attr_accessor :unicode
  def initialize (color = 'white', x = 0, y = 0, unicode)
    super(color, x, y)
    @unicode = unicode
  end
  def valid_move?(destination)
    m, n = destination
    return false unless m.between?(0, 7) && n.between?(0, 7) && !(m == @position_x && n == @position_y)
    if (m - @position_x).abs == (n - @position_y).abs
      @path = find_path(destination)
      return true
    else 
      return false
    end    
  end
end

class Pawn < Piece
  attr_accessor :unicode
  def initialize (color = 'white', x = 0, y = 0, unicode)
    super(color, x, y)
    @unicode = unicode
  end
  def valid_move?(destination)
    m, n = destination
    return false unless m.between?(0, 7) && n.between?(0, 7) && !(m == @position_x && n == @position_y)
    if n == @position_y
      if @color == 'white' 
        if m - @position_x == 1 || (m - @position_x == 2 && m == 3)
          @path = []
          for i in (@position_x + 1)..(m - 1)
            @path << [i, n]
          end
          return true
        end
      else
        if m - @position_x == -1 || (m - @position_x == -2 && m == 4)
          @path = []
          for i in (m + 1)..(@position_x - 1)
            @path << [i, n]
          end
          return true
        end
      end
    elsif (n - @position_y).abs == 1
      if @color == 'white' 
        if m - @position_x == 1
          @path = []
          return true
        end
      else
        if m - @position_x == -1
          @path = []
          return true
        end
      end
    end 
    return false   
  end
end