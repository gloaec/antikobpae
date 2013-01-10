class CreateScans < ActiveRecord::Migration
  def self.up
    create_table :scans do |t|
      t.references :folder
      t.boolean :sphinx, :default => true, :null => false
      t.boolean :web, :default => true, :null => false
      t.boolean :recursive, :default => true, :null => false
      t.integer :tolerence, :default => AppConfig.default_tolerence, :null => false
      t.references :target_folders
      t.timestamps
    end
  end
  
  def self.down
    drop_table :scans
  end
end
