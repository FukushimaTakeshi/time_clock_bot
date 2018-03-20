require 'rails_helper'
require_relative '../../../lib/bot/follow'

describe 'Bot::Follow' do
  describe 'create' do
    it 'ユーザが作成される' do
      expect {
        Bot::Follow.new('test_id').create
      }.to change(User, :count).by(1)
    end
  end
end
