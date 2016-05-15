class CreateLottoGames < ActiveRecord::Migration
  def change
    create_table :lotto_games do |t|
      t.string :name
      t.string :group_name
      t.string :draw_days
      t.boolean :active

      t.timestamps null: false
    end
  end
end
