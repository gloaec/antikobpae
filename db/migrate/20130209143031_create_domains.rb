class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.references :folder
      t.string :uri

      t.timestamps
    end
    add_index :domains, :folder_id
  end
end
