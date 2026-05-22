# frozen_string_literal: true

module Telegram
  module Commands
    module Spreadsheets
      class AddExpenseService < BaseService
        attr_reader :expense

        record :user
        string :document_id
        boolean :show_rest_balance, default: false
        object :expense_data, class: ExpenseType
        object :upsert_expense_service, default: UpsertExpenseService, class: UpsertExpenseService.class.name
        object :document_rest_balance_service, class: 'Class', default: DocumentRestBalanceService
        object :save_input_service, class: 'Class', default: AddExpenseSaveInputService

        def execute
          errors.add(:could_not_find_spreadsheet, 'No Spreadsheet') unless spreadsheet
          call if errors.empty?
          render_view(view, expense: expense, rest_balance: rest_balance)
        end

        private

        def call
          publish_expense
          rest_balance
        end

        def publish_expense
          spreadsheet.expenses.new(**expense_data).tap do |new_expense|
            return errors.add(:upsert_expense, 'Fail to upsert expense') unless upsert_expense
            return errors.add(:invalid_record, 'Fail to save expense') unless new_expense.save

            @expense = new_expense
          end

          error.add(:save_input, 'Fail to save inputs') unless save_input_service.run(
            user: user, document_id: spreadsheet.document_id, expense_data: expense_data
          ).valid?
        end

        def rest_balance
          @rest_balance = begin
            return unless show_rest_balance
            return unless rest_balance_response

            rest_balance_response
          end
        end

        def upsert_expense
          upsert_expense_service.run(spreadsheet: spreadsheet, expense: expense_data).result
        end

        def view
          return :could_not_find_spreadsheet if errors[:could_not_find_spreadsheet].presence
          return :invalid_record if errors[:invalid_record].presence

          :success
        end

        def rest_balance_response
          @rest_balance_response ||= document_rest_balance_service.run!(
            document_id: document_id, cell: spreadsheet.rest_balance_cell
          )
        end

        def spreadsheet
          @spreadsheet ||= Spreadsheet.find_by(document_id: document_id, user_id: user.id)
        end

        def template(view)
          "telegram/commands/spreadsheets/add_expense/#{view}"
        end
      end
    end
  end
end
