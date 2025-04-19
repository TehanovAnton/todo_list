class TodosController < ApplicationController
  def create
    todo = Todo.create(
      **create_params.except(:category_ids),
      user_id: current_user.id
    )

    if create_params[:category_ids].present?
      categories = Category.where(id: create_params[:category_ids])
      todo.categories << categories
    end

    head :ok
  end

  private

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, category_ids: [])
  end
end
