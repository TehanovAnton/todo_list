class CreatTodoModel < ActiveRecord::Migration[7.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :due_date
      t.boolean :completed, default: false
      t.integer :priority
      t.references :category, foreign_key: true
      
      t.timestamps
    end
  end
end
