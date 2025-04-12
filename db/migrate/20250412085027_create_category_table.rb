class CreateCategoryTable < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :categorizable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
