class LottoResult < ActiveRecord::Base
  
  def to_s
    return self.as_json
  end
end
