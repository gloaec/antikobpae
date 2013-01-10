class AddTimeToScanFiles < ActiveRecord::Migration
  def change
    add_column :scan_files, :time, :string
  end
end
