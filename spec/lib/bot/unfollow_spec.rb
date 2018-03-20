require 'rails_helper'
require_relative '../../../lib/bot/unfollow'

describe 'Bot::Unfollow' do
  describe 'delete' do
    it 'ユーザが削除される' do
      User.create(line_user_id: 'test_id')
      expect {
        Bot::Unfollow.new('test_id').delete
      }.to change(User, :count).by(-1)
    end
  end
end
