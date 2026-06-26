# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Commands::Spreadsheets::SetAliasService, type: :service do
  let(:user) { create(:user) }
  let(:document_id) { 'test_document_123' }
  let(:alias_value) { 'Бюджет' }

  describe '#run!' do
    subject { described_class.run(user: user, document_id: document_id, alias: alias_value).result }

    context 'when spreadsheet exists for user' do
      let!(:spreadsheet) { create(:spreadsheet, user: user, document_id: document_id) }

      it 'updates alias' do
        expect { subject }.to change { spreadsheet.reload.alias }.from(nil).to(alias_value)
      end

      it 'returns success message' do
        expect(subject).to eq("Alias \"#{alias_value}\" установлен для #{document_id}")
      end

      context 'when alias is already taken by another spreadsheet of the same user' do
        before { create(:spreadsheet, user: user, document_id: 'other_doc', alias: alias_value) }

        it 'does not update alias' do
          expect { subject }.not_to(change { spreadsheet.reload.alias })
        end

        it 'returns invalid_record message' do
          expect(subject).to eq('Не удалось установить alias: такой alias уже используется')
        end
      end

      context 'when same alias exists for another user' do
        let(:other_user) { create(:user) }

        before { create(:spreadsheet, user: other_user, document_id: 'other_doc_456', alias: alias_value) }

        it 'updates alias' do
          expect { subject }.to change { spreadsheet.reload.alias }.from(nil).to(alias_value)
        end
      end
    end

    context 'when spreadsheet does not exist' do
      it 'returns not found message' do
        expect(subject).to eq('Таблица не найдена')
      end
    end

    context 'when spreadsheet belongs to another user' do
      let(:other_user) { create(:user) }

      before { create(:spreadsheet, user: other_user, document_id: document_id) }

      it 'returns not found message' do
        expect(subject).to eq('Таблица не найдена')
      end
    end
  end
end
