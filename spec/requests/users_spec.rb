require 'rails_helper'
require 'rails/test_help'

RSpec.describe 'Users', type: :request do

  describe 'GET /signup #new' do
    context 'ログイン状態の場合' do
      before do
        @user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        @user.create_activation_digest
        get edit_account_activation_url(@user.activation_token, id: 'line12345678')
      end
      it 'httpステータスコード200を返すこと' do
        get new_signup_path(id: @user.id)
        expect(response).to have_http_status(200)
      end
      it 'ユーザ名が表示されていること' do
        get new_signup_path(id: @user.id)
        expect(response.body).to include('test_user')
      end
    end
  end

  describe 'GET /user/:id #show' do
    context 'ログイン状態の場合' do
      before do
        @user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        @user.create_activation_digest
        get edit_account_activation_url(@user.activation_token, id: 'line12345678')
      end
      it 'httpステータスコード200を返すこと' do
        get user_path(id: @user.id)
        expect(response).to have_http_status(200)
      end
      it 'ユーザ名が表示されていること' do
        get user_path(id: @user.id)
        expect(response.body).to include('test_user')
      end
    end
  end
end
