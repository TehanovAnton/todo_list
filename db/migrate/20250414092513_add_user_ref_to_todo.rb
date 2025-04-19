class AddUserRefToTodo < ActiveRecord::Migration[7.0]
  def change
    add_reference :todos, :user, foregin_key: :true
  end
end
