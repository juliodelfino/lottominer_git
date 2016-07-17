class AddJackpotPrizeToLottoGame < ActiveRecord::Migration
  def change
    add_column :lotto_games, :current_jackpot_prize, :integer
  end
end
