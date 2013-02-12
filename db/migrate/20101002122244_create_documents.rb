class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :name
      t.integer :status
	    t.integer :words_length
	    t.integer :chars_length
      t.string :attachment_file_type
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.string :from, :default => 'file', :null => 'file'
      #t.boolean :delta, :boolean, :default => false, :null => false
      t.boolean :text_only, :default => false, :null => false
      t.references :folder
      t.references :user
      t.references :content 
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
