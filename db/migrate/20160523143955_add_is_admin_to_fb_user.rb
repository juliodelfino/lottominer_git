class AddIsAdminToFbUser < ActiveRecord::Migration
  def change
    add_column :fb_users, :is_admin, :boolean, :default => false
  end
end
