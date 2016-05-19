class AddLottoGameToLottoResult < ActiveRecord::Migration
  def change
    add_column :lotto_results, :lotto_game_id, :integer
    add_column :lotto_results, :sorted_numbers, :string
  end
end
