class CreateSimilarities < ActiveRecord::Migration
  def change
    create_table :similarities do |t|
      
      t.references :scan_file_duplicate_range
      t.references :document_duplicate_range
      t.references :scan_file
      t.references :document
      t.boolean :is_exception
      t.boolean :is_validated

      t.timestamps
    end
  end
end
