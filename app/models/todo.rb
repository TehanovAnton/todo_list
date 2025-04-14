class Todo < ApplicationRecord
  has_many :categories, as: :categorizable
end
