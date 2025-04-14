class Todo < ApplicationRecord
  has_many :categories, as: :categorizable
  belongs_to :user
end
