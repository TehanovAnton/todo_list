# frozen_string_literal: true

module Telegram
  class CommandMessageHandlerService < ApplicationInteraction
    record :user
    string :message_text

    def execute
      commands_registry[command_params.command].call
    rescue ActiveInteraction::InvalidInteractionError, StandardError => e
      Yabeda.interaction_errors_total.increment(interaction: self.class.name.demodulize.underscore, type: e.class.name)
      ErrorLogger.log(e, context: { interaction: self.class.name })
      render_view(:fail)
    end

    private

    def commands_registry
      @commands_registry ||= {
        list_all: method(:list_all_command),
        add: method(:add_command),
        delete: method(:delete_command),
        add_expense: method(:add_expense_command),
        rest_balance: method(:rest_balance_command),
        set_alias: method(:set_alias_command)
      }
    end

    def list_all_command
      Commands::Spreadsheets::ListAllService.run!(user: user)
    end

    def add_command
      ApplicationLogger.log(message: 'Add Command')

      Commands::Spreadsheets::AddService.run!(
        user: user,
        document_id: command_params.document_id,
        expense_range: command_params.expense_range,
        rest_balance_cell: command_params.rest_balance_cell,
        alias: command_params.alias
      )
    end

    def delete_command
      Commands::Spreadsheets::DeleteService.run!(
        user: user, document_id: command_params.document_id
      )
    end

    def add_expense_command
      ApplicationLogger.log(message: 'Add Expense Command')

      document_id = command_params.document_id
      alias_name = command_params.alias

      unless document_id || alias_name
        document_id = saved_input.document_id
        alias_name = saved_input.alias
      end

      Commands::Spreadsheets::AddExpenseService.run!(
        user: user,
        document_id: document_id,
        alias_name: alias_name,
        show_rest_balance: command_params.show_rest_balance,
        expense_data: Commands::Spreadsheets::ExpenseType.new(
          date: command_params.date || saved_input.date,
          amount: command_params.amount || saved_input.amount,
          category: command_params.category || saved_input.category,
          comment: command_params.comment || saved_input.comment
        )
      )
    end

    def set_alias_command
      ApplicationLogger.log(message: 'Set Alias Command')

      Commands::Spreadsheets::SetAliasService.run!(
        user: user,
        document_id: command_params.document_id,
        alias: command_params.alias
      )
    end

    def rest_balance_command
      Commands::Spreadsheets::RestBalanceService.run!(
        user: user,
        document_id: command_params.document_id,
        expected_balance: command_params.expected_balance,
        flag: command_params.flag
      )
    end

    def saved_input
      @saved_input ||= method("#{command_params.command}_saved_input").call
    end

    def add_expense_saved_input
      command_setting = user.add_expense_command_setting || AddExpenseCommandSetting.create!(user: user)
      command_setting.savable_input || AddExpenseSavedInput.create(command_setting: command_setting)

      user.add_expense_saved_input
    end

    def command_params
      CommandMessageParserService.run!(text: message_text)
    end

    def render_view(view, **locals)
      Commands::Spreadsheets::RenderService.run!(
        template: template(view),
        formats: [:text],
        locals: locals
      )
    end

    def template(view)
      "telegram/commands/spreadsheets/#{view}"
    end
  end
end
