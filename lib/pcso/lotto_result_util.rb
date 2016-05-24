class LottoResultUtil
    
   def self.parse(htmltext) 
     
     cells = htmltext.scan(/<td>.*?<\/td>/m)
     
     row = LottoResult.new(
       game:     cells[0].sub(/.*>(.*)<.*/, '\1'), 
       numbers:       cells[1].sub(/.*>(.*)<.*/, '\1'), 
       draw_date:     Date.strptime(cells[2].sub(/.*>(.*)<.*/, '\1'), "%m/%d/%Y"), 
       jackpot_prize: cells[3].sub(/.*>(.*)<.*/, '\1').gsub(',','').to_i, 
       winners:       cells[4].sub(/.*>(.*)<.*/, '\1').to_i)
     
     if (LottoResult.find_by(game: row.game, draw_date: row.draw_date).nil?)
        nums = row.numbers.split('-').map(&:to_i).sort
        row.sorted_numbers = '-' + nums.join('-') + '-'
        game = LottoGame.where(name: row.game)[0]
        row.lotto_game_id = game.id
       return row.save
     end
     
     return row
   end
   
end