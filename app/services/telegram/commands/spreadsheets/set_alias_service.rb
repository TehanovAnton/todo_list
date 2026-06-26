# frozen_string_literal: true

module Telegram
  module Commands
    module Spreadsheets
      class SetAliasService < BaseService
        record :user
        string :document_id, default: nil
        string :alias, default: nil

        def execute
          errors.add(:spreadsheet, 'Could not find spreadsheet') if spreadsheet.blank?

          update_spreadsheet if errors.empty?
          render_view(view, spreadsheet: spreadsheet)
        end

        private

        def update_spreadsheet
          errors.add(:invlaid_record, 'Fail to set alias') unless spreadsheet.update(alias: self.alias)
        end

        def view
          return :not_found if errors[:spreadsheet].present?
          return :invalid_record if errors[:invlaid_record].present?

          :success
        end

        def spreadsheet
          @spreadsheet ||= Spreadsheet.find_by(document_id: document_id, user_id: user.id)
        end

        def template(view)
          "telegram/commands/spreadsheets/set_alias/#{view}"
        end
      end
    end
  end
end
