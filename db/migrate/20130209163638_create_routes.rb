class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.references :domain

      t.timestamps
    end
    add_index :routes, :domain_id
  end
end
