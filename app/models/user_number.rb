class UserNumber < ActiveRecord::Base
  belongs_to :fb_user
  belongs_to :lotto_game
end
