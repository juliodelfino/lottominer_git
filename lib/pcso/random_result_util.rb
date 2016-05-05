class RandomResultUtil
    
    def self.generate_result
      result = LottoResult.create(game: "SuperLotto 6/49", numbers: generate_random(), won: false)
      result.save
      return result
    end
    
    def self.generate_random
      nums = []
      while nums.size < 6 do
        num = rand(1..49)
        unless nums.include?(num) 
          nums << num
        end
      end
      return nums.sort.join(" ")
    end
   
end