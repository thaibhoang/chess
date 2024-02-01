require_relative "../lib/board.rb"

describe Board do
  subject(:game_board) {described_class.new}
  describe '#make_board' do
    it 'make a 8 rows and 8 columns board' do
      expect(game_board.board.size).to be 8
      expect(game_board.board[0].size).to be 8
    end
  end

  describe '#place_pieces' do    
    it 'put the piece in to the position on the board, aka update the board cell' do
      game_board.place_pieces('king', [0, 4])
      expect(game_board.board[0][4]).to eq 'king'
    end
  end

  describe '#make_move' do
    let(:rook) {instance_double(Rook, :position_x => 0, :position_y => 0)}
    before do
      allow(game_board).to receive(:path_clear?).and_return(true)
      allow(rook).to receive(:valid_move?).and_return(true)
      allow(rook).to receive(:path)
      allow(rook).to receive(:color)
      allow(game_board).to receive(:ally_occupied?).and_return false
      allow(rook).to receive(:update_position)
    end    
    it 'not allow make move when the move is not valid for the piece' do
      allow(rook).to receive(:valid_move?).and_return(false)
      expect(game_board).to receive(:puts).once
      game_board.make_move(rook, [3, 3])
    end
    it 'not allow make move when the path not cleared' do
      allow(game_board).to receive(:path_clear?).and_return(false)
      expect(game_board).to receive(:puts).once
      game_board.make_move(rook, [3, 3])
    end
    it 'allow make move when the path cleared and move valid' do
      expect(game_board).not_to receive(:puts)
      game_board.make_move(rook, [3, 3])
    end
  end

  describe '#ally_occupied?' do
    let(:rook) {instance_double(Rook)}
    before do      
      game_board.board[3][3] = rook
    end

    it 'return false when the cel is nil' do
      expect(game_board.ally_occupied?('white', 3, 4)).to be false 
    end
    it 'returns true if there is an ally piece on the destination position' do
      allow(rook).to receive(:color).and_return('white')
      expect(game_board.ally_occupied?('white', 3, 3)).to be true      
    end
    it 'returns false if there is an enermy piece on the destination position' do
      allow(rook).to receive(:color).and_return('white')
      expect(game_board.ally_occupied?('black', 3, 3)).to be false      
    end
  end

  describe '#path_clear?' do
    path = [[4, 1], [4, 2], [4, 3]] 
    it "returns true if there no piece in the path array" do      
      expect(game_board.path_clear?(path)).to be true
    end

    it "returns false if there is a piece in the path array" do   
      game_board.board[4][3] = instance_double(Rook)   
      expect(game_board.path_clear?(path)).to be false
    end
  end

  describe '#update_position' do
    let(:rook) {instance_double(Rook, :position_x => 3, :position_y => 3)}
    
    before do
      game_board.board[3][3] = rook
      allow(rook).to receive(:update_position)
    end

    it 'reset the old position to nil' do
      expect {game_board.update_position(rook, [3, 5])}.to change {game_board.board[3][3]}.to nil
    end
    it 'update the new position to the piece' do
      expect {game_board.update_position(rook, [3, 5])}.to change {game_board.board[3][5]}.to rook
    end
    it 'send the update_oisition message to piece' do
      expect(rook).to receive(:update_position).with(3, 5)
      game_board.update_position(rook, [3, 5])
    end
  end

  describe '#under_diagonal_attack?' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 4)}
    let(:white_queen) {instance_double(Queen, color: 'white', position_x: 6, position_y: 7)}
    let(:white_knight) {instance_double(Knight, color: 'white', position_x: 5, position_y: 6)}

    before do
      game_board.board[3][4] = black_queen
      game_board.board[6][7] = white_queen
      allow(white_queen).to receive(:instance_of?).with(Queen).and_return true
    end
    it 'return true if the black queen has a white queen on its diagonal without any pieces in between ' do
      expect(game_board.under_diagonal_attack?('black', 3, 4)).to be true
    end
    it 'return false if the black queen has a white queen on its diagonal but has a white knight in between ' do
      game_board.board[5][6] = white_knight      
      expect(game_board.under_diagonal_attack?('black', 3, 4)).to be false
    end
    it 'return false if there is no enermy queen or bitshop in two diagonals and it work with nil cell' do    
      expect(game_board.under_diagonal_attack?('black', 3, 5)).to be false
    end
  end

  describe '#under_vertical_or_horizontal_attack?' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 3)}
    let(:white_queen) {instance_double(Queen, color: 'white', position_x: 3, position_y: 7)}
    let(:white_knight) {instance_double(Knight, color: 'white', position_x: 3, position_y: 5)}
    let(:king) {instance_double(King, been_moved: false, position_x:0, position_y:4, color:'white')}
    let(:black_queen2) {instance_double(Queen, position_x:5, position_y:4, color:'black')}
    
    before do
      game_board.board[0][4] = king
      game_board.board[3][3] = black_queen
      game_board.board[3][7] = white_queen
      game_board.board[5][4] = black_queen2
      allow(white_queen).to receive(:instance_of?).with(Queen).and_return true
      allow(black_queen2).to receive(:instance_of?).with(Queen).and_return true
    end
    it 'return true if the black queen has a white queen on the same row without any pieces in between ' do
      expect(game_board.under_vertical_or_horizontal_attack?('black', 3, 3)).to be true
    end

    it 'return true if the king is attack by blackqueen 2' do
      expect(game_board.under_vertical_or_horizontal_attack?('white', 0, 4)).to be true
    end

    it 'return false if the black queen has a white queen on the same row buthas a white knight in between ' do
      game_board.board[3][5] = white_knight
      expect(game_board.under_vertical_or_horizontal_attack?('black', 3, 3)).to be false
    end
  end

  describe '#under_knight_attack?' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 3)}
    let(:white_knight) {instance_double(Knight, color: 'white', position_x: 4, position_y: 5)}  
    before do
      allow(white_knight).to receive(:instance_of?).and_return true
      game_board.board[3][3] = black_queen
    end
    it 'return true if there is an enermy knight attaking the position' do
      game_board.board[4][5] = white_knight
      expect(game_board.under_knight_attack?('black', 3, 3)).to be true
    end

    it 'return false if there is not any enermy knights attaking the position' do
      game_board.board[4][6] = white_knight
      expect(game_board.under_knight_attack?('black', 3, 3)).to be false
    end
  end

  describe '#under_pawn_attack?' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 3)}
    let(:white_queen) {instance_double(Queen, color: 'white', position_x: 3, position_y: 7)}
    let(:white_pawn) {instance_double(Pawn, color: 'white', position_x: 2, position_y: 4)}  
    let(:black_pawn) {instance_double(Pawn, color: 'black', position_x: 4, position_y: 6)}  
    before do
      allow(white_pawn).to receive(:instance_of?).and_return true
      allow(black_pawn).to receive(:instance_of?).and_return true
      game_board.board[3][3] = black_queen
      game_board.board[3][7] = white_queen
      game_board.board[2][4] = white_pawn
      game_board.board[4][6] = black_pawn
    end
    it 'return true when black queen under white pawn attack' do
      expect(game_board.under_pawn_attack?('black', 3, 3)).to be true
    end

    it 'return true when white queen under black pawn attack' do
      expect(game_board.under_pawn_attack?('white', 3, 7)).to be true
    end
  end

  describe '#king_out_of_legal_move?' do
    let(:black_king) {instance_double(King, color: 'black', position_x: 3, position_y: 3)}
    let(:black_pawn1) {instance_double(Pawn, color: 'black', position_x: 3, position_y: 2)}
    let(:black_pawn2) {instance_double(Pawn, color: 'black', position_x: 3, position_y: 4)}
    let(:black_pawn3) {instance_double(Pawn, color: 'black', position_x: 2, position_y: 3)}
    let(:black_pawn4) {instance_double(Pawn, color: 'black', position_x: 4, position_y: 3)}
    let(:black_pawn5) {instance_double(Pawn, color: 'black', position_x: 2, position_y: 2)}
    let(:black_pawn6) {instance_double(Pawn, color: 'black', position_x: 2, position_y: 4)}
    let(:black_pawn7) {instance_double(Pawn, color: 'black', position_x: 4, position_y: 4)}
    let(:black_pawn8) {instance_double(Pawn, color: 'black', position_x: 4, position_y: 2)}
    let(:white_queen1) {instance_double(Queen, color: 'white', position_x: 1, position_y: 3)}
    let(:white_queen2) {instance_double(Queen, color: 'white', position_x: 5, position_y: 3)}
    let(:white_queen3) {instance_double(Queen, color: 'white', position_x: 3, position_y: 1)}
    let(:white_queen4) {instance_double(Queen, color: 'white', position_x: 3, position_y: 5)}
    before do
      allow(white_queen1).to receive(:instance_of?).and_return false
      allow(white_queen2).to receive(:instance_of?).and_return false
      allow(white_queen3).to receive(:instance_of?).and_return false
      allow(white_queen4).to receive(:instance_of?).and_return false
      allow(white_queen1).to receive(:instance_of?).with(Queen).and_return true
      allow(white_queen2).to receive(:instance_of?).with(Queen).and_return true
      allow(white_queen3).to receive(:instance_of?).with(Queen).and_return true
      allow(white_queen4).to receive(:instance_of?).with(Queen).and_return true
    end
    it 'returns true when king all surrouned by allies' do
      game_board.board[3][2] = black_pawn1
      game_board.board[3][4] = black_pawn2
      game_board.board[2][3] = black_pawn3
      game_board.board[4][3] = black_pawn4
      game_board.board[2][2] = black_pawn5
      game_board.board[2][4] = black_pawn6
      game_board.board[4][4] = black_pawn7
      game_board.board[4][2] = black_pawn8
      expect(game_board.king_out_of_legal_move?(black_king)).to be true
    end
    it 'returns true when all surrouned cells are under attacked' do
      game_board.board[1][3] = white_queen1
      game_board.board[5][3] = white_queen2
      game_board.board[3][1] = white_queen3
      game_board.board[3][5] = white_queen4
      expect(game_board.king_out_of_legal_move?(black_king)).to be true
    end
  end

  describe '#find_path_under_diagonal_attack' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 4)}
    let(:white_queen) {instance_double(Queen, color: 'white', position_x: 6, position_y: 7)}

    before do
      game_board.board[3][4] = black_queen
      game_board.board[6][7] = white_queen
      allow(white_queen).to receive(:instance_of?).and_return false  
      allow(white_queen).to receive(:instance_of?).with(Queen).and_return true  
    end
    it 'returns the path when the black queen under white queen attack' do
      expect(game_board.find_path_under_diagonal_attack('black', 3, 4)).to eq [[4,5], [5,6], [6,7]]
    end   
  end

  describe '#find_path_under_vertical_or_horizontal_attack' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 4)}
    let(:white_queen) {instance_double(Queen, color: 'white', position_x: 3, position_y: 7)}

    before do
      game_board.board[3][4] = black_queen
      game_board.board[3][7] = white_queen
      allow(white_queen).to receive(:instance_of?).and_return false  
      allow(white_queen).to receive(:instance_of?).with(Queen).and_return true  
    end
    it 'returns the path when the black queen under white queen attack' do
      expect(game_board.find_path_under_vertical_or_horizontal_attack('black', 3, 4)).to eq [[3,5], [3,6], [3,7]]
    end   
  end

  describe '#find_path_under_vertical_or_horizontal_attack' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 3)}
    let(:white_knight) {instance_double(Knight, color: 'white', position_x: 4, position_y: 5)}  
    before do
      allow(white_knight).to receive(:instance_of?).with(Knight).and_return true
      game_board.board[3][3] = black_queen
    end
    it 'return true if there is an enermy knight attaking the position' do
      game_board.board[4][5] = white_knight
      expect(game_board.find_path_under_knight_attack('black', 3, 3)).to eq [[4,5]]
    end
  end

  describe '#find_path_under_vertical_or_horizontal_attack' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 3)}
    let(:white_knight) {instance_double(Knight, color: 'white', position_x: 4, position_y: 5)}  
    before do
      allow(white_knight).to receive(:instance_of?).with(Knight).and_return true
      game_board.board[3][3] = black_queen
    end
    it 'return true if there is an enermy knight attaking the position' do
      game_board.board[4][5] = white_knight
      expect(game_board.find_path_under_knight_attack('black', 3, 3)).to eq [[4,5]]
    end
  end

  describe '#find_path_under_pawn_attack' do
    let(:black_queen) {instance_double(Queen, color: 'black', position_x: 3, position_y: 3)}
    let(:white_queen) {instance_double(Queen, color: 'white', position_x: 3, position_y: 7)}
    let(:white_pawn) {instance_double(Pawn, color: 'white', position_x: 2, position_y: 4)}  
    let(:black_pawn) {instance_double(Pawn, color: 'black', position_x: 4, position_y: 6)}  
    before do
      allow(white_pawn).to receive(:instance_of?).and_return true
      allow(black_pawn).to receive(:instance_of?).and_return true
      game_board.board[3][3] = black_queen
      game_board.board[3][7] = white_queen
      game_board.board[2][4] = white_pawn
      game_board.board[4][6] = black_pawn
    end
    it 'return true when black queen under white pawn attack' do
      expect(game_board.find_path_under_pawn_attack('black', 3, 3)).to eq [[2,4]]
    end
    it 'return true when white queen under black pawn attack' do
      expect(game_board.find_path_under_pawn_attack('white', 3, 7)).to eq [[4,6]]
    end
  end

  describe '#can_castling?' do
    let(:king) {instance_double(King, been_moved: false, position_x:0, position_y:4, color:'white')}
    let(:left_rook) {instance_double(Rook, been_moved: false, position_x:0, position_y:0, color:'white')}
    let(:black_queen) {instance_double(Queen, position_x:5, position_y:4, color:'black')}
    let(:white_left_knight) {instance_double(Knight, position_x:0, position_y:1, color:'white')}

    before do
      game_board.board[0][4] = king
      game_board.board[0][0] = left_rook
      allow(black_queen).to receive(:instance_of?).with(Queen).and_return true      
    end    
    it 'return true if there is no piece between king and rook' do
      expect(game_board.can_castling?(king, left_rook)).to be true
    end
    it 'return false if there is a piece between king and rook' do
      game_board.board[0][2] = white_left_knight
      expect(game_board.can_castling?(king, left_rook)).to be false
    end
    it 'return false if the king is under attack' do
      game_board.board[5][4] = black_queen
      expect(game_board.can_castling?(king, left_rook)).to be false
    end
  end
end

