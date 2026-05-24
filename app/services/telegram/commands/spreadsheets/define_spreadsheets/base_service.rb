# frozen_string_literal: true

module Telegram
  module Commands
    module Spreadsheets
      module DefineSpreadsheets
        class BaseService < ApplicationInteraction
          record :user
          string :document_id, default: nil
          string :alias_name, default: nil

          def execute
            lookup_strategies[lookup_strategy_name].call
          end

          private

          def lookup_strategy_name
            lookup_data.keys.first
          end

          def lookup_data
            @lookup_data ||= {
              document_id: document_id,
              alias_name: alias_name,
              save_input_document_id: save_input.document_id,
              save_input_alias_name: save_input.alias
            }.compact
          end

          def lookup_strategies
            {
              document_id: method(:by_document_id),
              alias_name: method(:by_alias_name),
              save_input_document_id: method(:by_save_input_document_id),
              save_input_alias_name: method(:by_save_input_alias_name)
            }
          end

          def by_document_id
            Spreadsheet.find_by(document_id: lookup_data[:document_id], user_id: user.id)
          end

          def by_alias_name
            Spreadsheet.find_by(alias: lookup_data[:alias_name], user_id: user.id)
          end

          def by_save_input_document_id
            Spreadsheet.find_by(document_id: lookup_data[:save_input_document_id], user_id: user.id)
          end

          def by_save_input_alias_name
            Spreadsheet.find_by(alias: lookup_data[:save_input_alias_name], user_id: user.id)
          end

          def save_input
            raise NotImplementedError
          end
        end
      end
    end
  end
end
