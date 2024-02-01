require_relative '../lib/board.rb'
require_relative '../lib/player.rb'
require 'pry'

class Game
  def initialize
    @white_player = Player.new('white')
    @black_player = Player.new('black')
    @white_turn = true
    @board = Board.new
    @board.setup_piece_board
  end  
  def find_piece_from_infor(piece_name, start_row, start_col, color)
    piece_wanted = nil
    if color == 'white'
      @board.white.each do |key, value|   
        condition1 = false
        condition2 = true
        condition3 = true   
        case piece_name          
        when 'K'
          condition1 = true if value.instance_of?(King)          
        when 'Q'
          condition1 = true if value.instance_of?(Queen)          
        when 'R'
          condition1 = true if value.instance_of?(Rook)          
        when 'B'
          condition1 = true if value.instance_of?(Bishop)          
        when 'N'
          condition1 = true if value.instance_of?(Knight)          
        when 'P'
          condition1 = true if value.instance_of?(Pawn)          
        end

        next if !condition1
        condition2 = false if start_row != nil && value.position_x != start_row
        condition3 = false if start_col != nil && value.position_y != start_col      
        if condition1 && condition2 && condition3
          piece_wanted = value
          return piece_wanted
        end
      end
    else
      @board.black.each do |key, value|
        condition1 = false
        condition2 = true
        condition3 = true  
        case piece_name
        when 'K'
          condition1 = true if value.instance_of?(King)          
        when 'Q'
          condition1 = true if value.instance_of?(Queen)          
        when 'R'
          condition1 = true if value.instance_of?(Rook)          
        when 'B'
          condition1 = true if value.instance_of?(Bishop)          
        when 'N'
          condition1 = true if value.instance_of?(Knight)          
        when 'P'
          condition1 = true if value.instance_of?(Pawn)          
        end
        next if !condition1
        condition2 = false if start_row != nil && value.position_x != start_row
        condition3 = false if start_col != nil && value.position_y != start_col
        if condition1 && condition2 && condition3
          piece_wanted = value
          return piece_wanted
        end
      end
    end
  end

  def start_game
    while true
      if @board.check_mate?(@board.white[:king]) || @board.check_mate?(@board.black[:king])
        @board.print_board
        winning_color = @white_turn ? "black" : "white"
        puts "Game ended, #{winning_color} wins. Hooray!!"
        break
      end 
      @board.print_board
      des_row, des_col, piece_name, start_row, start_col, color = @white_turn ? @white_player.get_move : @black_player.get_move
      piece = find_piece_from_infor(piece_name, start_row, start_col, color)
      if @board.check?("black") 
        common_path = @board.find_common_path('white', @board.white[:king].position_x, @board.white[:king].position_y)
        if piece_name != 'K' && !common_path.include?([des_row, des_col])
          puts "You need to protext your King"
          next
        end
      elsif @board.check?("white")
        common_path = @board.find_common_path('black', @board.black[:king].position_x, @board.black[:king].position_y)
        if piece_name != 'K' && !common_path.include?([des_row, des_col])
          puts "You need to protext your King"
          next
        end
      end   
      @white_turn = @white_turn ? false : true if @board.make_move(piece, [des_row, des_col]) 
    end
  end
end

game = Game.new
game.start_game