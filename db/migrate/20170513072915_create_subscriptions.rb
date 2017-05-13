class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.string :email, null: true
      t.boolean :enabled, :default => true
      t.boolean :notify_daily_results, :default => true
      t.boolean :notify_personal_num_info, :default => true

      t.timestamps
    end
    
     add_index :subscriptions, :email, unique: true
  end
end
