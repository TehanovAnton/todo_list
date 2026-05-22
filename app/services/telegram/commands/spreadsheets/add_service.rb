# frozen_string_literal: true

module Telegram
  module Commands
    module Spreadsheets
      class AddService < BaseService
        record :user
        string :document_id
        string :expense_range
        string :rest_balance_cell

        def execute
          errors.add(:document_id, 'Must to be present') if document_id.blank?
          errors.add(:expense_range, 'Must to be present') if expense_range.blank?

          create_spreadsheet if errors.empty?

          render_view(view, spreadsheet: spreadsheet)
        end

        private

        def create_spreadsheet
          errors.add(:invalid_record, 'Could not create spreadsheet') unless spreadsheet.valid?
        end

        def spreadsheet
          @spreadsheet ||= Spreadsheet.create(
            user: user, document_id: document_id, expense_range: expense_range, rest_balance_cell: rest_balance_cell
          )
        end

        def view
          @view = begin
            return :invalid_record if errors[:invalid_record].present?

            :success
          end
        end

        def template(view)
          "telegram/commands/spreadsheets/add/#{view}"
        end
      end
    end
  end
end
