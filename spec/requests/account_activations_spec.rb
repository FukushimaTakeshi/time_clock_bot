require 'rails_helper'

RSpec.describe 'AccountActivations', type: :request do

  describe 'GET /account_activations/:token #edit' do
    context '有効なユーザの場合' do
      before do
        @user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        @user.create_activation_digest
        get edit_account_activation_path(token: @user.activation_token, id: @user.line_user_id)
      end
      it 'httpステータスコード302を返すこと' do
        expect(response).to have_http_status(302)
      end
      it 'ユーザ登録画面にリダイレクトすること' do
        expect(response).to redirect_to(new_signup_url(id: @user.id))
      end
    end

    context '無効なユーザの場合' do
      before { get edit_account_activation_path(token: '1qaz2wsx', id: '123') }
      it 'httpステータスコード302を返すこと' do
        expect(response).to have_http_status(302)
      end
      it 'homeにリダイレクトすること' do
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
