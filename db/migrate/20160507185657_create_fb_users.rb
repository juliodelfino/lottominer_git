class CreateFbUsers < ActiveRecord::Migration
  def change
    create_table :fb_users do |t|
      t.string :fb_id
      t.string :name
      t.string :email
      t.string :mobile_no
      t.string :photo
      t.text :fb_info

      t.timestamps null: false
    end
  end
end
