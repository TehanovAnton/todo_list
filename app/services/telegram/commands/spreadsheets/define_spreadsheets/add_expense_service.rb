# frozen_string_literal: true

module Telegram
  module Commands
    module Spreadsheets
      module DefineSpreadsheets
        class AddExpenseService < BaseService
          private

          def save_input
            user.add_expense_saved_input
          end
        end
      end
    end
  end
end
