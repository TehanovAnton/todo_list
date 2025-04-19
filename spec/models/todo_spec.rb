require 'rails_helper'

describe Todo, type: :model do
  subject { create(:todo) }

  let(:category) { subject.categories.first }

  it do
    expect(subject.categories).to include(category)
  end
end
