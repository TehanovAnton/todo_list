# frozen_string_literal: true

require 'rails_helper'

describe Telegram::CommandMesageHandlerService do
  subject(:result) { described_class.run!(user: user, message_text: text) }

  let(:user) { FactoryBot.create(:user) }

  describe '/spreadsheets --add_expense command' do
    let(:document_id) { 'test-doc-id' }
    let!(:spreadsheet) { FactoryBot.create(:spreadsheet, user: user, document_id: document_id) }
    let(:rest_balance) { '5000.0' }
    let(:base_text) do
      %(spreadsheets
        --add_expense --document_id="#{document_id}" --date="17.05.2026" --amount="100" --category="Продукты"
      )
    end

    before do
      allow(Telegram::Commands::Spreadsheets::UpsertExpenseService).to receive(:run)
        .and_return(OpenStruct.new(result: true))
    end

    context 'when --show_rest_balance flag is present' do
      let(:text) { "/#{base_text} --show_rest_balance" }

      before do
        allow(Telegram::Commands::Spreadsheets::DocumentRestBalanceService)
          .to receive(:run!)
          .with(document_id: document_id, cell: spreadsheet.rest_balance_cell)
          .and_return(rest_balance)
      end

      it 'includes rest_balance in response' do
        expect(result).to include("Остаток: #{rest_balance}")
      end
    end

    describe 'save_input_service work' do
      context 'when saves input' do
        let(:text) { "/#{base_text}" }

        it do
          result
          user.reload

          saved_input = user.add_expense_saved_input
          expect(saved_input).to be_present
          expect(saved_input.document_id).to eq(document_id)
          expect(saved_input.amount).to be_present
          expect(saved_input.category).to eq('Продукты')
        end
      end

      context 'when saved_inputs are used' do
        let(:saved_category) { 'Продукты' }
        let(:text) { '/spreadsheets --add_expense --date="17.05.2026" --amount="100"' }
        let!(:saved_input) do
          FactoryBot.create(:add_expense_saved_input, document_id: document_id, category: saved_category)
        end

        before do
          user.create_add_expense_command_setting!(savable_input: saved_input)

          allow(Telegram::Commands::Spreadsheets::AddExpenseService).to receive(:run!)
        end

        it 'uses document_id and category from saved_input' do
          result

          expect(Telegram::Commands::Spreadsheets::AddExpenseService).to have_received(:run!).with(
            hash_including(
              document_id: document_id,
              expense_data: having_attributes(category: saved_category)
            )
          )
        end
      end
    end
  end

  describe '/spreadsheets --add command' do
    before do
      allow(Telegram::Commands::Spreadsheets::UpsertExpenseService).to receive(:run)
        .and_return(OpenStruct.new(result: true))
    end

    describe 'success cases' do
      let(:rest_balance) { 'Лист1!M7' }
      let(:text) do
        '/spreadsheets --add --document_id="new-doc" --expense_range="Sheet1!A1:B1" --rest_balance_cell="Лист1!M7"'
      end
      let(:new_spreadsheet) { user.spreadsheets.last }

      it do
        expect(result.class).to be(String)
        expect(new_spreadsheet).to be_valid
      end
    end
  end
end
