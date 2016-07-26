class AddStatusToUserNumber < ActiveRecord::Migration
  def change
    add_column :user_numbers, :status, :string
  end
end
