class CreateScanFiles < ActiveRecord::Migration
  def change
    create_table :scan_files do |t|
      t.references :scan
      t.references :document
      t.integer :status
      t.decimal :progress, :default => 0
      t.decimal :sphinx_progress, :default => 0
      t.decimal :web_progress, :default => 0
      t.integer :dup_words
      t.integer :dup_chars
      t.string  :time
      t.decimal :word_score, :precision => 6, :scale => 3
      t.decimal :char_score, :precision => 6, :scale => 3
	    t.decimal :score, :precision => 6, :scale => 3
      t.timestamps
    end
  end
end
