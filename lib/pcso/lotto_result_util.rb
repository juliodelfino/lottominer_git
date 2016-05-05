class LottoResultUtil
    
   def self.parse(htmltext) 
     
     cells = htmltext.scan(/<td>.*?<\/td>/m)
     
     row = LottoResult.new(
       game:     cells[0].sub(/.*>(.*)<.*/, '\1'), 
       numbers:       cells[1].sub(/.*>(.*)<.*/, '\1'), 
       draw_date:     Date.strptime(cells[2].sub(/.*>(.*)<.*/, '\1'), "%m/%d/%Y"), 
       jackpot_prize: cells[3].sub(/.*>(.*)<.*/, '\1').gsub(',','').to_i, 
       winners:       cells[4].sub(/.*>(.*)<.*/, '\1').to_i)
     
     lotto_result = LottoResult.find_or_create_by(row.attributes)


     return lotto_result
   end
   
end