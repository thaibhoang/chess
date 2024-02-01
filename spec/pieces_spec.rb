require_relative '../lib/pieces.rb'

describe King do
  subject(:king) {described_class.new('white', 0, 4)}
  describe '#valid_move?' do    
    it 'return true when the king move to a cell next to it'do
      expect(king.valid_move?([0,5])).to be true
    end
    it 'return false when the king move to a cell not next to it'do
      expect(king.valid_move?([0,7])).to be false
    end
    it 'return false when the king move to a cell not exist'do
      expect(king.valid_move?([0,-1])).to be false
    end
  end
end

describe Queen do
  subject(:queen) {described_class.new('white', 0, 3, 'random unicode')}
  describe '#valid_move?' do 
    it 'return true when the queen move to a cell on the diagonal'do
      expect(queen.valid_move?([4,7])).to be true
    end
    it 'return true when the queen move to a cell on the same row'do
      expect(queen.valid_move?([0,7])).to be true
    end
    it 'return true when the queen move to a cell on the same col'do
      expect(queen.valid_move?([7,3])).to be true
    end
    it 'return false when the queen move to a invalid cell'do
      expect(queen.valid_move?([6,5])).to be false
    end
  end
end

describe Rook do
  subject(:rook) {described_class.new('white', 0, 0, 'random unicode')}
  describe '#valid_move?' do 
    it 'return false when the rook move to a cell on the diagonal'do
      expect(rook.valid_move?([4,4])).to be false
    end
    it 'return true when the rook move to a cell on the same row'do
      expect(rook.valid_move?([0,7])).to be true
    end
    it 'return true when the rook move to a cell on the same col'do
      expect(rook.valid_move?([7,0])).to be true
    end
    it 'return false when the rook move to a invalid cell'do
      expect(rook.valid_move?([0,0])).to be false
    end
  end
end

describe Knight do
  subject(:knight) {described_class.new('white', 0, 1, 'random unicode')}
  describe '#valid_move?' do 
    it 'return false when the knight move to a cell on the diagonal'do
      expect(knight.valid_move?([4,5])).to be false
    end
    it 'return false when the knight move to a cell on the same row'do
      expect(knight.valid_move?([0,7])).to be false
    end
    it 'return true when the knight move to a valid cell'do
      expect(knight.valid_move?([2,2])).to be true
    end
    it 'return false when the knight move to a invalid cell'do
      expect(knight.valid_move?([0,1])).to be false
    end
  end
end

describe Pawn do
  subject(:pawn) {described_class.new('white', 1, 1, 'random unicode')}
  describe '#valid_move?' do 
    it 'return false when the pawn move to a cell on the diagonal'do
      expect(pawn.valid_move?([2,3])).to be false
    end
    it 'return false when the pawn move to a cell on the same row'do
      expect(pawn.valid_move?([1,3])).to be false
    end
    it 'return true when the pawn move to a valid cell'do
      expect(pawn.valid_move?([3,1])).to be true
    end
    it 'return false when the pawn move to a invalid cell'do
      expect(pawn.valid_move?([1,1])).to be false
    end
  end
end