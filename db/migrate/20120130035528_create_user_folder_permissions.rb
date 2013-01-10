class CreateUserFolderPermissions < ActiveRecord::Migration
  def self.up
    create_table :user_folder_permissions do |t|
      t.references :folder
      t.references :user
      t.boolean :can_create
      t.boolean :can_read
      t.boolean :can_update
      t.boolean :can_delete
    end
  end
  def self.down
    drop_table :user_folder_permissions
  end
end