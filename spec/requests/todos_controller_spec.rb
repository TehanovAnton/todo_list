# frozen_string_literal: true

require 'rails_helper'

describe 'TodosControllers', type: :request do
  include_context 'devise user login'

  describe 'create' do
    let(:user) { create(:user) }
    let(:category) { create(:category) }

    let(:params) do
      {
        todo: {
          title: 'Sample Todo',
          description: 'This is a sample description',
          due_date: '2023-12-31',
          category_ids: [category.id]
        }
      }
    end

    let(:todo) { category.reload.todos.last }

    it 'creates a new todo and associates it with the category' do
      post '/todos', params: params

      expect(response).to have_http_status(:ok)
      expect(todo.title).to eq('Sample Todo')
      expect(todo.description).to eq('This is a sample description')

      expect(category.todos).not_to be_empty
    end
  end
end
