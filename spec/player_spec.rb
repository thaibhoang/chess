require_relative '../lib/player.rb'

describe Player do
  subject(:player) {described_class.new}
  describe '#get_move' do  
    it 'loops twice when give 1 invalid input and then 1 valid input' do   
      allow(player).to receive(:gets).and_return('Qg55', 'Qg5')   
      expect(player).to receive(:puts).exactly(3).times
      player.get_move
    end

    it 'loops three times when give 1 invalid input and then 1 valid input' do   
      allow(player).to receive(:gets).and_return('Qg55', 'Qewg5', 'Qg5')   
      expect(player).to receive(:puts).exactly(4).times
      player.get_move
    end
  end
end