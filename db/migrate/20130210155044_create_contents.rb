class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.references :document
      t.text :text

      t.boolean :delta, :boolean, :default => true, :null => false
      t.timestamps
    end
    add_index :contents, :document_id
  end
end
