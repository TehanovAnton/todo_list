# frozen_string_literal: true

class Spreadsheet < ApplicationRecord
  belongs_to :user

  has_many :expenses, dependent: nil

  validates :document_id, presence: true
  validates :expense_range, presence: true
  validates :alias, uniqueness: { scope: :user_id }, allow_nil: true
end
