class AddSortedNumbersToUserNumber < ActiveRecord::Migration
  def change
    add_column :user_numbers, :sorted_numbers, :string
  end
end
