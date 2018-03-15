require 'rails_helper'

RSpec.describe 'Users', type: :request do

  describe 'GET /signup/:id #new' do
    context 'ログイン状態の場合' do
      before do
        user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        user.create_activation_digest
        get edit_account_activation_url(user.activation_token, id: 'line12345678')
        get new_signup_path(id: user.id)
      end
      it 'httpステータスコード200を返すこと' do
        expect(response).to have_http_status(200)
      end
      it 'ユーザ名が表示されること' do
        expect(response.body).to include('test_user')
      end
    end

    context '未ログイン状態の場合' do
      before do
        user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        get new_signup_path(id: user.id)
      end
      it 'httpステータスコード302を返すこと' do
        expect(response).to have_http_status(302)
      end
      it 'homeにリダイレクトすること' do
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET /user/:id #show' do
    context 'ログイン状態の場合' do
      before do
        user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        user.create_activation_digest
        get edit_account_activation_url(user.activation_token, id: 'line12345678')
        get user_path(id: user.id)
      end
      it 'httpステータスコード200を返すこと' do
        expect(response).to have_http_status(200)
      end
      it 'メッセージが表示されること' do
        expect(response.body).to include('こんちは! こんちは!')
      end
    end
  end

  describe 'PATCH /signup/:id #update' do
    context 'ログイン状態の場合' do
      before do
        @user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        @user.create_activation_digest
        get edit_account_activation_url(@user.activation_token, id: 'line12345678')
      end

      context 'パラメータが正常な場合' do
        before { patch update_signup_path(id: @user.id), params: { user: { user_id: 'tie999999', password: '1qaz"WSX' } } }
        it 'httpステータスコード302を返すこと' do
          expect(response).to have_http_status(302)
        end
        it '#showへリダイレクトすること' do
          expect(response).to redirect_to(user_path(id: @user.id))
        end
      end

      context 'パラメータが不正な場合' do
        before { patch update_signup_path(id: @user.id), params: { user: { user_id: 'tie999999', password: '' } } }
        it 'httpステータスコード200を返すこと' do
          expect(response).to have_http_status(200)
        end
        it 'エラーが表示されること' do
          expect(response.body).to include('The form contains 1 error')
        end
      end
    end
  end

  describe 'DELETE /user/:id #destroy' do
    context 'ログイン状態の場合' do
      before do
        user = User.create(user_id: 'tie123456', password: 'P@ssw0rd', line_user_id: 'line12345678', line_display_name: 'test_user')
        user.create_activation_digest
        get edit_account_activation_url(user.activation_token, id: 'line12345678')
        delete user_path(id: user.id)
      end
      it 'httpステータスコード302を返すこと' do
        expect(response).to have_http_status(302)
      end
      it 'homeにリダイレクトすること' do
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
