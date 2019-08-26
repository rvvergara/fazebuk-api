# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:mike) { build(:user, first_name: 'Mike') }
    context 'complete basic info' do
      it 'is valid' do
        expect(mike).to be_valid
      end
    end

    context 'first_name absent' do
      it 'is invalid' do
        mike.first_name = nil
        expect(mike).to_not be_valid
      end
    end
  end
end
