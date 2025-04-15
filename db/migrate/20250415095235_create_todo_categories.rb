class CreateTodoCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_categories do |t|
      t.references :todo, foregin_key: true
      t.references :category, foregin_key: true

      t.timestamps
    end
  end
end
