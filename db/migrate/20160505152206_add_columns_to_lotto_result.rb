class AddColumnsToLottoResult < ActiveRecord::Migration
  def change
    add_column :lotto_results, :draw_date, :date
    add_column :lotto_results, :jackpot_prize, :integer
    add_column :lotto_results, :winners, :integer
  end
end
