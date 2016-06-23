class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :recipient
      t.string :subject
      t.text :body
      t.datetime :plan_send_date
      t.datetime :actual_send_date
      t.string :status

      t.timestamps null: false
    end
  end
end
