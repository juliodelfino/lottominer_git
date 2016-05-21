class LottoResult < ActiveRecord::Base
  belongs_to :lotto_game
  
  def to_s
    return self.as_json
  end
end
