# frozen_string_literal: true

class TodoCategory < ApplicationRecord
  belongs_to :todo
  belongs_to :category
end
