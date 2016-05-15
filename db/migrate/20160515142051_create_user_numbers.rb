class CreateUserNumbers < ActiveRecord::Migration
  def change
    create_table :user_numbers do |t|
      t.string :numbers
      t.integer :fb_user_id
      t.integer :lotto_game_id

      t.timestamps null: false
    end
  end
end
