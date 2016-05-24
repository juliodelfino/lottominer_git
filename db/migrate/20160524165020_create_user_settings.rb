class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.integer :fb_user_id
      t.string :email_verification
      t.boolean :notify_daily_results, :default => true

      t.timestamps null: false
    end
  end
end
