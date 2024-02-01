require_relative '../lib/pieces'

class Board
  attr_accessor :board, :black, :white, :recent_captured
  def initialize(init_board = make_board())
    @board = init_board
    @previous_two_step_advance_pawn = nil
    @black = {
      king: King.new('black', 7, 4, "\u265A"),
      queen: Queen.new("black",7,3, "\u265B"),
      rook1: Rook.new("black",7,0, "\u265C"),
      rook2: Rook.new("black",7,7, "\u265C"),
      knight1: Knight.new("black",7,1, "\u265E"),
      knight2: Knight.new("black",7,6, "\u265E"),
      bishop1: Bishop.new("black",7,2, "\u265D"),
      bishop2: Bishop.new("black",7,5, "\u265D"),
      pawn1: Pawn.new("black",6,0, "\u265F"),
      pawn2: Pawn.new("black",6,1, "\u265F"),
      pawn3: Pawn.new("black",6,2, "\u265F"),
      pawn4: Pawn.new("black",6,3, "\u265F"),
      pawn5: Pawn.new("black",6,4, "\u265F"),
      pawn6: Pawn.new("black",6,5, "\u265F"),
      pawn7: Pawn.new("black",6,6, "\u265F"),
      pawn8: Pawn.new("black",6,7, "\u265F")
    }
    @white = {
      king: King.new("white",0,4, "\u2654"),
      queen: Queen.new("white",0,3, "\u2655"),
      rook1: Rook.new("white",0,0, "\u2656"),
      rook2: Rook.new("white",0,7, "\u2656"),
      knight1: Knight.new("white",0,1, "\u2658"),
      knight2: Knight.new("white",0,6, "\u2658"),
      bishop1: Bishop.new("white",0,2, "\u2657"),
      bishop2: Bishop.new("white",0,5, "\u2657"),
      pawn1: Pawn.new("white",1,0, "\u2659"),
      pawn2: Pawn.new("white",1,1, "\u2659"),
      pawn3: Pawn.new("white",1,2, "\u2659"),
      pawn4: Pawn.new("white",1,3, "\u2659"),
      pawn5: Pawn.new("white",1,4, "\u2659"),
      pawn6: Pawn.new("white",1,5, "\u2659"),
      pawn7: Pawn.new("white",1,6, "\u2659"),
      pawn8: Pawn.new("white",1,7, "\u2659")
    }
  end

  def make_board
    Array.new(8).map {|row| row = Array.new(8)}
  end

  def setup_piece_board
    @black.each_value do |piece|

      x, y = piece.position_x, piece.position_y
      @board[x][y] = piece
    end
    @white.each_value do |piece|
      x, y = piece.position_x, piece.position_y
      @board[x][y] = piece
    end
    return @board
  end

  def place_pieces(piece, position)
    @board[position[0]][position[1]] = piece
  end

  def make_move(piece, destination)
    m, n = piece.position_x, piece.position_y
    x, y = destination
    # pawn capture
    if piece.instance_of?(Pawn) && piece.valid_move?(destination) && @board[x][y] != nil && @board[x][y].color != piece.color && (m-x).abs == 1 && (n-y).abs == 1 
      update_position(piece, destination)
      return true
    end
    # king castling
    if piece.instance_of?(King) && m == x && (n - y).abs == 2
      des = (y - n == 2) ? @board[x][y + 1] : @board[x][y - 2]
      if des.instance_of?(Rook) && can_castling?(piece, des)
        castling(piece, des)
      end
      return true
    end      
    if ally_occupied?(piece.color, x, y) || !(piece.valid_move?(destination) && path_clear?(piece.path))
      puts "the move is not valid for the piece"
      return false
    end
    update_position(piece, destination)
    return true
  end

  def ally_occupied?(color, x, y)
    return false if @board[x][y].nil? || color != @board[x][y].color
    return true
  end

  def path_clear?(path)
    return true if path.nil?
    for x, y in path
      return false if @board[x][y] != nil
    end
    return true
  end

  def update_position(piece, destination)
    x, y = destination
    @board[piece.position_x][piece.position_y] = nil
    piece.update_position(x, y)  
    if @board[x][y] != nil
      captured_piece = @board[x][y]
      piece_wanted_symbol = nil
      if captured_piece.color = 'white'
        @white.each_pair do |key, value|
          if value.position_x == captured_piece.position_x && value.position_y == captured_piece.position_y
            piece_wanted_symbol = key
          end
        end
        @white.delete(piece_wanted_symbol)
      else
        @black.each_pair do |key, value|
          if value.position_x == captured_piece.position_x && value.position_y == captured_piece.position_y
            piece_wanted_symbol = key
          end
        end
        @black.delete(piece_wanted_symbol)
      end
    end
    @board[x][y] = piece 
    piece.been_moved = true if piece.instance_of?(King) || piece.instance_of?(Rook)      
  end

  def check?(color_of_attacker)
    if color_of_attacker == 'black'
      return true if cell_under_attack?('white', white[:king].position_x, white[:king].position_y)
    else
      return true if cell_under_attack?('black', black[:king].position_x, black[:king].position_y)
    end
    return false
  end

  def cell_under_attack?(color, x, y)
    return true if under_diagonal_attack?(color, x, y)
    return true if under_vertical_or_horizontal_attack?(color, x, y)
    return true if under_knight_attack?(color, x, y)
    return true if under_pawn_attack?(color, x, y)
    return false
  end

  def find_first_piece_in_direction(a, b, x, y)
    return nil if !( x.between?(0, 7) && y.between?(0, 7) )
    return @board[x][y] if @board[x][y] != nil
    return find_first_piece_in_direction(a, b, x + a, y + b)
  end

  def find_path_in_direction(a, b, x, y, result)
    return result if !( x.between?(0, 7) && y.between?(0, 7) )
    return result << [x, y] if @board[x][y] != nil
    return find_path_in_direction(a, b, x + a, y + b, result << [x, y])
  end

  def under_diagonal_attack?(color, x, y)
    directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    for a, b in directions      
      next_piece = find_first_piece_in_direction(a, b, x + a, y + b)
      return true if next_piece != nil && next_piece.color != color && (next_piece.instance_of?(Queen) || next_piece.instance_of?(Bishop))
    end
    return false
  end

  def find_path_under_diagonal_attack(color, x, y)
    directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]] 
    all_path = []   
    for a, b in directions      
      path = find_path_in_direction(a, b, x + a, y + b, [])
      next if path.size == 0
      m, n = path[-1]
      next_piece = @board[m][n]
      if next_piece != nil && next_piece.color != color && (next_piece.instance_of?(Queen) || next_piece.instance_of?(Bishop))
        all_path += path
      end
    end
    return all_path
  end

  def under_vertical_or_horizontal_attack?(color, x, y)
    directions = [[1,0],[-1,0],[0,1],[0,-1]]
    for a, b in directions
      next_piece = find_first_piece_in_direction(a, b, x + a, y + b)
      return true if next_piece != nil && next_piece.color != color && (next_piece.instance_of?(Queen) || next_piece.instance_of?(Rook))
    end
    return false
  end

  def find_path_under_vertical_or_horizontal_attack(color, x, y)
    directions = [[1,0],[-1,0],[0,1],[0,-1]]
    all_path = []   
    for a, b in directions      
      path = find_path_in_direction(a, b, x + a, y + b, [])
      next if path.size == 0
      m, n = path[-1]
      next_piece = @board[m][n]
      if next_piece != nil && next_piece.color != color && (next_piece.instance_of?(Queen) || next_piece.instance_of?(Rook))
        all_path += path
      end
    end
    return all_path
  end

  def under_knight_attack?(color, x, y)
    directions = [[2,1],[2,-1],[-2,1],[-2,-1],[1,-2],[1,2],[-1,2],[-1,-2]]
    for a, b in directions
      next unless (x + a).between?(0, 7) && (y + b).between?(0, 7)
      next_piece = @board[x + a][y + b]
      return true if next_piece != nil && next_piece.color != color && next_piece.instance_of?(Knight)
    end
    return false
  end

  def find_path_under_knight_attack(color, x, y)
    directions = [[2,1],[2,-1],[-2,1],[-2,-1],[1,-2],[1,2],[-1,2],[-1,-2]]
    all_path = []   
    for a, b in directions  
      next unless (x + a).between?(0, 7) && (y + b).between?(0, 7)    
      next_piece = @board[x + a][y + b]
      if next_piece != nil && next_piece.color != color && next_piece.instance_of?(Knight)
        all_path += [[x + a, y + b]]
      end
    end
    return all_path
  end

  def under_pawn_attack?(color, x, y)
    directions = color == 'black' ? [[-1, 1], [-1, -1]] : [[1, 1], [1, -1]]
    for a, b in directions
      next unless (x + a).between?(0, 7) && (y + b).between?(0, 7)
      position = @board[x + a][y + b]
      return true if position != nil && position.color != color && position.instance_of?(Pawn)
    end
    return false
  end

  def find_path_under_pawn_attack(color, x, y)
    directions = color == 'black' ? [[-1, 1], [-1, -1]] : [[1, 1], [1, -1]]
    all_path = []   
    for a, b in directions    
      next unless (x + a).between?(0, 7) && (y + b).between?(0, 7)  
      position = @board[x + a][y + b]
      if position != nil && position.color != color && position.instance_of?(Pawn)
        all_path += [[x + a, y + b]]
      end
    end
    return all_path
  end  

  def find_ally_rook_queen_in_same_row_column(color, x, y)
    directions = [[1,0],[-1,0],[0,1],[0,-1]]
    result = []
    for a, b in directions
      next_piece = find_first_piece_in_direction(a, b, x + a, y + b)
      if next_piece != nil && next_piece.color == color && (next_piece.instance_of?(Queen) || next_piece.instance_of?(Rook))
        result << [next_piece.position_x, next_piece.position_y]
      end
    end
    return result
  end

  def find_ally_bishop_queen_in_same_diagonal(color, x, y)
    directions = [[1,1],[-1,-1],[1,-1],[-1,1]]
    result = []
    for a, b in directions
      next_piece = find_first_piece_in_direction(a, b, x + a, y + b)
      if next_piece != nil && next_piece.color == color && (next_piece.instance_of?(Queen) || next_piece.instance_of?(Bishop))
        result << [next_piece.position_x, next_piece.position_y]
      end
    end
    return result
  end

  def find_ally_knight_shieldable(color, x, y)
    directions = [[2,1],[2,-1],[-2,1],[-2,-1],[1,-2],[1,2],[-1,2],[-1,-2]]
    result = []   
    for a, b in directions  
      next unless (x + a).between?(0, 7) && (y + b).between?(0, 7)    
      next_piece = @board[x + a][y + b]
      if next_piece != nil && next_piece.color == color && next_piece.instance_of?(Knight)
        result += [[x + a, y + b]]
      end
    end
    return result
  end

  def find_ally_pawn_shieldable(color, x, y)
    direction = color == 'black' ? [1, 0] : [-1, 0]
    result = []   
    a, b = direction  
    return result unless (x + a).between?(0, 7)
    position = @board[x + a][y]
    if position != nil && position.color == color && position.instance_of?(Pawn)
      result += [[x + a, y]]
    end
    if position == nil && ((x + a == 5 && color == 'black') || (x + a == 2 && color == 'white'))
      new_position = @board[x + 2*a][y]
      if new_position != nil && new_position.color == color && new_position.instance_of?(Pawn)
        result += [[x + 2*a, y]]
      end
    end
    return result
  end

  def find_ally_piece_can_move_to_position(color, x, y)
    result = []
    result += find_ally_pawn_shieldable(color, x, y)
    result += find_ally_knight_shieldable(color, x, y)
    result += find_ally_rook_queen_in_same_row_column(color, x, y)
    result += find_ally_bishop_queen_in_same_diagonal(color, x, y)
    result
  end

  def find_common_path(color, x, y)
    attack_angle = 0
    pawn_path = find_path_under_pawn_attack(color, x, y)
    knight_path = find_path_under_knight_attack(color, x, y) 
    ver_hor_path = find_path_under_vertical_or_horizontal_attack(color, x, y) 
    diga_path = find_path_under_diagonal_attack(color, x, y)
    danger_paths = []
    for path in [pawn_path, knight_path, ver_hor_path, diga_path]
      if path.size > 0
        attack_angle += 1
        danger_paths << path
      end
    end
    common_path = danger_paths.reduce do |result, element|
      result & element
    end
    return common_path
  end

  def shieldable(color, x, y)    
    common_path = find_common_path(color, x, y)
    return false if common_path.size == 0
    can_be_shielded = false
    for shield_position in common_path
      m, n = shield_position
      potential_king_saviors = find_ally_piece_can_move_to_position(color, m, n)
      for savior in potential_king_saviors
        initial_destination_piece = @board[m][n]
        initial_savior_position = [savior.position_x, savior.position_y]      
        update_position(savior, [m, n])
        if !check?(color == 'white' ? 'black' : 'white')
          can_be_shielded = true 
        end
        update_position(savior, initial_savior_position)
        @board[m][n] = initial_destination_piece
        break if can_be_shielded
      end
    end
    return can_be_shielded
  end

  def king_out_of_legal_move?(king)
    color, x, y = king.color, king.position_x, king.position_y
    king_surround_positions = [[1,1],[-1,-1],[-1,1],[1,-1],[0,1],[0,-1],[1,0],[-1,0]]
    move_choices = king_surround_positions.size
    for a, b in king_surround_positions
      move_choices -= 1 if !((x + a).between?(0,7) && (y + b).between?(0,7)) || ally_occupied?(color, x + a, y + b) || cell_under_attack?(color, x + a, y + b)
    end
    return true if move_choices == 0
    return false
  end

  def check_mate?(king)
    color, x, y = king.color, king.position_x, king.position_y
    return true if king_out_of_legal_move?(king) && cell_under_attack?(color, x, y) && !shieldable(color, x, y)
    return false
  end

  def can_castling?(king, rook)
    return false if king.been_moved || rook.been_moved || king.color != rook.color
    
    color = king.color
    x, y = king.position_x, king.position_y
    m, n = rook.position_x, rook.position_y
    check_points = (n < y) ? [[x, y-1], [x, y-2]] : [[x, y+1], [x, y+2]]
    for e, f in check_points
      return false if cell_under_attack?(color, e, f) || @board[e][f] != nil
    end    
    return false if cell_under_attack?(color, x, y)
    if y - n == 4
      return false if ally_occupied?(color, x, y-3) 
    end
    return true
  end

  def castling(king, rook)
    if !can_castling?(king, rook)
      puts "connot castling"
    else
      x, y = king.position_x, king.position_y
      m, n = rook.position_x, rook.position_y
      check_points = (n < y) ? [[x, y], [x, y-1], [x, y-2]] : [[x, y], [x, y+1], [x, y+2]]
      update_position(king, check_points[2])
      update_position(rook, check_points[1])
    end
  end

  def en_passant(piece)
    return if @previous_two_step_advance_pawn.nil? || !piece.instance_of?(Pawn) || piece.color != @previous_two_step_advance_pawn.color
    pre_pawn = @previous_two_step_advance_pawn
    x, y = pre_pawn.position_x, pre_pawn.position_y
    directions = pre_pawn.color == 'white' ? [[-1, -1], [-1, 1]] : [[1, -1], [1, 1]]
    m, n = piece.position_x, piece.position_y
    return if !directions.include? [m - x, n - y] 
    update_position(piece, x, y)
  end

  def get_promotion_info
    puts 'type in the piece you want to make (lowercase, no spacing)'
    accepted_input = ['queen', 'rook', 'bishop', 'knight']
    loop do
      new_piece = gets.chomp
      return new_piece if accepted_input.include? new_piece
      puts 'Hey you need to type in one of these value: queen, rook, bishop, knight'
    end
  end

  def promotion(pawn)
    def create_key (name)
      n = 2
      while @white.key? (name + n.to_s)
        n += 1
      end
      key = (name + n.to_s).to_sym
    end
    piece_type = get_promotion_info
    piece = nil
    x, y = pawn.position_x, pawn.position_y
    case piece_type
    when 'queen'
      piece = Queen.new(pawn.color, )
    when 'rook'
      piece = Rook.new(pawn.color, x, y)
    when 'bishop'
      piece = Bishop.new(pawn.color, x, y)
    when 'knight'
      piece = Knight.new(pawn.color, x, y)
    end
    place_pieces(piece, [x, y])
    if piece.color == 'white'
      case piece.class
      when Queen
        key = create_key ('queen')
        @white[key] = piece
      when Rook
        key = create_key ('rook')
        @white[key] = piece
      when Bishop
        key = create_key ('bishop')
        @white[key] = piece
      when Knight
        key = create_key ('knight')
        @white[key] = piece
      end
      @white.each do |key, value|
        @white.delete(key) if value == pawn
      end
    else
      case piece.class
      when Queen
        key = create_key ('queen')
        @black[key] = piece
      when Rook
        key = create_key ('rook')
        @black[key] = piece
      when Bishop
        key = create_key ('bishop')
        @black[key] = piece
      when Knight
        key = create_key ('knight')
        @black[key] = piece
      end
      @black.each do |key, value|
        @black.delete(key) if value == pawn
      end
    end
  end

  def print_board
    col = 'abcdefgh'
    print '   '
    for j in 0..7
      print ' '
      print col[j]      
    end
    puts
    print '  -'
    for j in 0..7
      print '--'      
    end
    print '--'
    puts
    (0..7).reverse_each do |i|
      print "#{i+1} | "
      for j in 0..7
        cell = @board[i][j]
        if cell == nil
          print "_ "
        else
          print "#{cell.unicode} "
        end
      end
      puts "| #{i+1}"
    end
    print '  -'
    for j in 0..7
      print '--'      
    end
    print '--' 
    puts
    print '   '
    for j in 0..7
      print ' '
      print col[j]      
    end
    puts    
  end
end
