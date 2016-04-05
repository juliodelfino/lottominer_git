class CreateLottoResults < ActiveRecord::Migration
  def change
    create_table :lotto_results do |t|
      t.string :game
      t.string :numbers
      t.boolean :won

      t.timestamps null: false
    end
  end
end
