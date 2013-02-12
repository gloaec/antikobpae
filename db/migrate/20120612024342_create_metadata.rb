class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.string :key
      t.string :value
      t.references :document
      t.boolean :delta, :boolean, :default => true, :null => false
      t.timestamps
    end
  end
end
