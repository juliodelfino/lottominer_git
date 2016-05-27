class FbUser < ActiveRecord::Base
  has_many :user_numbers
  has_one :user_setting
end
