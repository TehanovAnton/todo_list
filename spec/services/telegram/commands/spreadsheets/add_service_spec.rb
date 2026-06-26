# frozen_string_literal: true

require 'rails_helper'

describe Telegram::Commands::Spreadsheets::AddService do
  subject(:result) do
    described_class.run(
      user: user,
      document_id: document_id,
      expense_range: expense_range,
      rest_balance_cell: rest_balance_cell
    ).result
  end

  let(:user) { FactoryBot.create(:user) }
  let(:document_id) { 'doc-1' }
  let(:expense_range) { 'Sheet1!A1:B1' }
  let(:rest_balance_cell) { 'Лист1!M7' }

  describe 'success cases' do
    context 'when record is created' do
      it 'renders success view' do
        expect { result }.to change(Spreadsheet, :count).by(1)
        expect(result).to eq('Таблица создана')
      end
    end
  end

  describe 'alias' do
    subject(:result) do
      described_class.run(
        user: user,
        document_id: document_id,
        expense_range: expense_range,
        rest_balance_cell: rest_balance_cell,
        alias: alias_value
      ).result
    end

    let(:alias_value) { 'Бюджет' }

    context 'when alias is provided' do
      it 'creates spreadsheet with alias' do
        expect { result }.to change(Spreadsheet, :count).by(1)
        expect(Spreadsheet.last.alias).to eq(alias_value)
      end

      it 'renders success view' do
        expect(result).to eq('Таблица создана')
      end
    end
  end

  describe 'fail cases' do
    context 'when document_id is blank' do
      subject(:interaction) { described_class.run(user: user, document_id: '', expense_range: expense_range) }

      it 'is invalid' do
        expect(interaction).to be_invalid
      end
    end

    context 'when expense_range is blank' do
      subject(:interaction) { described_class.run(user: user, document_id: document_id, expense_range: '') }

      it 'is invalid' do
        expect(interaction).to be_invalid
      end
    end

    context 'when record is invalid' do
      let(:invalid_spreadsheet) { Spreadsheet.new(user: user, document_id: document_id, expense_range: nil) }

      before do
        allow(Spreadsheet).to receive(:create).and_return(invalid_spreadsheet)
      end

      it 'renders invalid_record view' do
        expect(result).to eq('Не получилось создать запись')
      end
    end
  end
end
