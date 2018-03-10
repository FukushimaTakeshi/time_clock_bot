require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#valid' do
    subject(:user) do
      User.new(user_id: user_id, password: password)
    end
    let(:user_id) { 'tie123456' }
    let(:password) { 'P@ssw0rd' }

    it { is_expected.to be_valid(:update) }

    describe 'user_id' do
      context '空の場合' do
        let(:user_id) { '' }
        it { is_expected.to_not be_valid(:update) }
      end
      context '長さ境界値超の場合' do
        let(:user_id) { 'a' * 8 }
        it { is_expected.to_not be_valid(:update) }
      end
    end

    describe 'password' do
      context '空の場合' do
        let(:password) { '' }
        it { is_expected.to_not be_valid(:update) }
      end
    end

    describe 'digest' do
      # user.update_attribute(:remember_digest, User.digest(User.new_token))
    end
  end
end
