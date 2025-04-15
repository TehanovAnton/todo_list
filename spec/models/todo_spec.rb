require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:category) { Category.create(name: :yellow) }
  let(:todo) { described_class.create(title: 'my todo', categories: [category]) }

  it do
    expect(todo.categories).to include(category)
  end
end
