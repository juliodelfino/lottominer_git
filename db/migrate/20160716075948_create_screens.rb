class CreateScreens < ActiveRecord::Migration
  def change
    create_table :screens do |t|
      t.string :data_type
      t.string :content
      t.string :schedule
      t.integer :duration
      t.integer :order
      t.boolean :visible

      t.timestamps null: false
    end
  end
end
