class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :document
       t.has_attached_file :attachment

      t.timestamps
    end
  end
end
