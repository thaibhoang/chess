class Player
  attr_accessor :color
  def initialize (color = 'white')
    @color = color
  end
  def get_move
    puts "Please type in your move"
    columns = 'abcdefgh'
    piece = ''
    start_col, start_row = nil, nil
    loop do
      puts "Remember that your move need to following the notation rule of chess"
      input = gets.chomp
      next if input.size < 2 || input.size > 5 
      
      next if !((1..8).include?(input[-1].to_i) && columns.include?(input[-2]))
      des_row = input[-1].to_i - 1
      des_col = columns.index(input[-2])
      if input.size == 2
        piece = 'P' 
        start_col = des_col
      elsif input.size == 3
        piece = input[0]
        next if !'KQRBNP'.include?(piece)
      elsif input.size == 4
        piece = input[0]
        next if !'KQRBNP'.include?(piece)
        next if input[-3] != 'x' && !columns.include?(input[-3]) && !(1..8).include?(input[-3].to_i)
        if columns.include?(input[-3])
          start_col = columns.index(input[-3])
        elsif (1..8).include?(input[-3].to_i)
          start_row = input[-3].to_i - 1
        end
      else
        piece = input[0]
        next if !'KQRBNP'.include?(piece) || input[-3] != 'x'
        next if !columns.include?(input[-4]) && !(1..8).include?(input[-4].to_i)
        if columns.include?(input[4])
          start_col = columns.index(input[-4])
        elsif (1..8).include?(input[-4].to_i)
          start_row = input[-4].to_i - 1
        end
      end
      return [des_row, des_col, piece, start_row, start_col, @color]
    end
  end

end