# frozen_string_literal: true

module Telegram
  module Commands
    class AddExpenseSaveInputService < ApplicationInteraction
      record :user
      string :document_id, default: nil
      string :alias_name, default: nil
      object :expense_data, class: Spreadsheets::ExpenseType

      def execute
        saved = begin
          user.add_expense_saved_input.update!(build_attrs)
        rescue ActiveRecord::ActiveRecordError
          nil
        end

        errors.add(:save_input) unless saved
      end

      private

      def build_attrs
        {
          alias: alias_name,
          document_id: document_id,
          date: expense_data.date,
          amount: expense_data.amount,
          category: expense_data.category,
          comment: expense_data.comment
        }.compact
      end
    end
  end
end
