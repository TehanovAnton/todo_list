# frozen_string_literal: true

module Telegram
  module Commands
    module Spreadsheets
      class ListAllService < BaseService
        record :user

        def execute
          render_view(:index, spreadsheets: spreadsheets)
        end

        private

        def spreadsheets
          @spreadsheets ||= Spreadsheet.where(user_id: user.id)
        end

        def template(view)
          "telegram/commands/spreadsheets/list_all/#{view}"
        end
      end
    end
  end
end
