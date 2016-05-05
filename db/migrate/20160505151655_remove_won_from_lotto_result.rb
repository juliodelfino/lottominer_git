class RemoveWonFromLottoResult < ActiveRecord::Migration
  def change
    remove_column :lotto_results, :won, :boolean
  end
end
