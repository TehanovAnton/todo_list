class AddAliasToAddExpenseSavedInputs < ActiveRecord::Migration[7.0]
  def change
    add_column :add_expense_saved_inputs, :alias, :string
  end
end
