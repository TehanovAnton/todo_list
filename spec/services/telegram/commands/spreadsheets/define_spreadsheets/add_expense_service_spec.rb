# frozen_string_literal: true

require 'rails_helper'

describe Telegram::Commands::Spreadsheets::DefineSpreadsheets::AddExpenseService do
  subject(:result) do
    described_class.run(
      user: user,
      document_id: document_id,
      alias_name: alias_name
    ).result
  end

  let(:user) { FactoryBot.create(:user) }
  let(:spreadsheet) { FactoryBot.create(:spreadsheet, user: user) }
  let(:document_id) { nil }
  let(:alias_name) { nil }
  let!(:saved_input) { FactoryBot.create(:add_expense_saved_input) }
  let!(:command_setting) { user.create_add_expense_command_setting!(savable_input: saved_input) }

  describe 'by_document_id' do
    let(:document_id) { spreadsheet.document_id }

    context 'when spreadsheet exists' do
      it 'returns the spreadsheet' do
        expect(result).to eq(spreadsheet)
      end
    end

    context 'when document_id does not match any spreadsheet' do
      let(:document_id) { 'unknown' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe 'by_alias_name' do
    let!(:spreadsheet) { FactoryBot.create(:spreadsheet, user: user, alias: 'Бюджет') }
    let(:alias_name) { 'Бюджет' }

    context 'when spreadsheet with alias exists for user' do
      it 'returns the spreadsheet' do
        expect(result).to eq(spreadsheet)
      end
    end

    context 'when alias belongs to another user' do
      let(:spreadsheet) { FactoryBot.create(:spreadsheet, alias: 'Бюджет') }

      it 'returns nil' do
        spreadsheet
        expect(result).to be_nil
      end
    end
  end

  describe 'by_save_input_document_id' do
    before { saved_input.update!(document_id: spreadsheet.document_id) }

    context 'when spreadsheet matches saved_input document_id' do
      it 'returns the spreadsheet' do
        expect(result).to eq(spreadsheet)
      end
    end

    context 'when saved_input document_id matches no spreadsheet' do
      before { saved_input.update!(document_id: 'unknown') }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe 'by_save_input_alias_name' do
    let!(:spreadsheet) { FactoryBot.create(:spreadsheet, user: user, alias: 'Бюджет') }

    before { saved_input.update!(alias: 'Бюджет') }

    context 'when spreadsheet with saved_input alias exists for user' do
      it 'returns the spreadsheet' do
        expect(result).to eq(spreadsheet)
      end
    end

    context 'when alias belongs to another user' do
      let!(:other_spreadsheet) { FactoryBot.create(:spreadsheet, document_id: 'other-doc', alias: 'Бюджет') }
      let!(:spreadsheet) { FactoryBot.create(:spreadsheet, user: user, document_id: 'user-doc') }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
