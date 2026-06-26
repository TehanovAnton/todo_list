# frozen_string_literal: true

require 'rails_helper'

describe Telegram::Commands::Spreadsheets::AddExpenseService do
  subject(:result) do
    described_class.run(
      user: user,
      document_id: document_id,
      expense_data: expense_data,
      show_rest_balance: show_rest_balance
    ).result
  end

  let(:user) { FactoryBot.create(:user) }
  let!(:saved_input) do
    FactoryBot.create(:add_expense_saved_input, document_id: document_id)
  end
  let!(:add_expense_command_setting) { user.create_add_expense_command_setting!(savable_input: saved_input) }
  let(:spreadsheet) { FactoryBot.create(:spreadsheet, user: user) }
  let(:document_id) { spreadsheet.document_id }
  let(:expense_data) { FactoryBot.build(:expense_type) }
  let(:show_rest_balance) { false }

  before do
    allow(Telegram::Commands::Spreadsheets::UpsertExpenseService).to receive(:run)
      .and_return(OpenStruct.new(result: true))
  end

  shared_examples 'render view' do |args|
    before do
      allow(ApplicationController).to receive(:render)
        .with(hash_including(template: args[:template])).once
        .and_return('Ok')
    end

    it do
      expect(result.class).to eq(String)
    end
  end

  describe 'success cases' do
    it_behaves_like 'render view', template: 'telegram/commands/spreadsheets/add_expense/success'

    describe 'show_rest_balance' do
      let(:show_rest_balance) { true }
      let(:rest_balance) { '5000.0' }

      before do
        allow(Telegram::Commands::Spreadsheets::DocumentRestBalanceService)
          .to receive(:run!)
          .with(document_id: document_id, cell: spreadsheet.rest_balance_cell)
          .and_return(rest_balance)
      end

      it 'calls DocumentRestBalanceService' do
        result
        expect(Telegram::Commands::Spreadsheets::DocumentRestBalanceService)
          .to have_received(:run!).once
      end
    end
  end

  describe 'fail cases' do
    shared_context 'when unkown document_id' do
      let(:document_id) { 'unknown' }
    end

    shared_context 'when spreadsheet of other user' do
      let(:spreadsheet) { FactoryBot.create(:spreadsheet) }
      let(:document_id) { spreadsheet.document_id }
    end

    shared_context 'when invalid expense' do
      let(:expense_data) { FactoryBot.build(:expense_type, amount: '-100') }
    end

    shared_examples 'render view scenarios' do |args|
      args[:scenarios].each do |scenario|
        context scenario[:name] do
          include_context scenario[:context]

          it_behaves_like 'render view', template: scenario[:template]
        end
      end
    end

    it_behaves_like 'render view scenarios', scenarios: [
      {
        name: 'when unknown spreadsheet',
        context: 'when unkown document_id',
        template: 'telegram/commands/spreadsheets/add_expense/could_not_find_spreadsheet'
      },
      {
        name: 'when spreadsheet of other user',
        context: 'when spreadsheet of other user',
        template: 'telegram/commands/spreadsheets/add_expense/could_not_find_spreadsheet'
      },
      {
        name: 'when invlaid expense',
        context: 'when invalid expense',
        template: 'telegram/commands/spreadsheets/add_expense/invalid_record'
      }
    ]
  end
end
