class AddAliasToSpreadsheet < ActiveRecord::Migration[7.0]
  def change
    add_column :spreadsheets, :alias, :string
    add_index :spreadsheets, [:alias, :user_id], unique: true
  end
end
