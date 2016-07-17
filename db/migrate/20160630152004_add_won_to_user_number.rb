class AddWonToUserNumber < ActiveRecord::Migration
  def change
    add_column :user_numbers, :won, :boolean, :default => false
  end
end
