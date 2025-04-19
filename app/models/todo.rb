class Todo < ApplicationRecord
  has_many :todo_categories
  has_many :categories, through: :todo_categories
end
