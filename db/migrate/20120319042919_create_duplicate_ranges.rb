class CreateDuplicateRanges < ActiveRecord::Migration
  def change
    create_table :duplicate_ranges do |t|
      
      t.integer :from_word
      t.integer :to_word
      t.integer :from_char
      t.integer :to_char

      t.timestamps
    end
  end
end
