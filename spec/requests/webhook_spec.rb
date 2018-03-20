require 'rails_helper'
require 'webmock/rspec'

WebMock.allow_net_connect!

RSpec.describe 'Webhook', type: :request do

  describe 'POST /callback #callback' do
    before do
      stub_request(:post, 'https://api.line.me/v2/bot/message/reply').to_return { |request| { body: 'OK', status: 200 } }
    end
    context 'LINE友達追加時' do
      let(:json_body) do
        {
          events: [{
            type: 'follow',
            replyToken: 'ef229106f3ef45679b5e8abdc855e8c4',
            source: {
              userId: 'U11dcf2ab1d8608c6a',
              type: 'user'
            },
            timestamp: '1515847809615'
          }],
          webhook: {
            events: [{
              type: 'follow',
              replyToken: 'ef229106f3ef45679b5e8abdc855e8c4',
              source: {
                userId: 'U11dcf2ab1d8608c6a',
                type: 'user'
              },
              timestamp: '1515847809615'
            }]
          }
        }
      end
      it 'ユーザ作成されること' do
        expect {
          post callback_path, params: json_body.to_json
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(204)
      end
    end

    context 'LINE友達削除時' do
      let(:json_body) do
        {
          events: [{
            type: 'unfollow',
            source: {
              userId: 'U11dcf2ab1d8608c6a',
              type: 'user'
            },
            timestamp: '1515847679590' }],
          webhook: {
            events: [{
              type: 'unfollow',
              source: {
                userId: 'U11dcf2ab1d8608c6a',
                type: 'user'
              },
              timestamp: '1515847679590'
            }]
          }
        }
      end
      before { User.create(line_user_id: 'U11dcf2ab1d8608c6a') }
      it 'ユーザ削除されること' do
        expect {
          post callback_path, params: json_body.to_json
        }.to change(User, :count).by(-1)
        expect(response).to have_http_status(204)
      end
    end

    context '通常メッセージ' do
      let(:json_body) do
        {
          events: [{
            type: 'message',
            replyToken: "9a68727b1ee34d84a7c1323549dc2cce",
            source: {
              userId: "U11dcf2ab1d8608c6a",
              type: "user"
            },
            timestamp: 1521286274866,
            message: {
              type: "text",
              id: "7639986520165",
              text: "逋ｻ骭ｲ縺吶ｋ"
            } }],
          webhook: {
            events: [{
              type: "message",
              replyToken: "9a68727b1ee34d84a7c1323549dc2cce",
              source: {
                userId: "U11dcf2ab1d8608c6a",
                type: "user"
              },
              timestamp: 1521286274866,
              message: {
                type: "text",
                id: "7639986520165",
                text: "登録する"
              }
            }]
          }
        }
      end
      context 'ユーザが存在しない場合' do
        it 'ユーザ作成されること' do
          expect {
            post callback_path, params: json_body.to_json
          }.to change(User, :count).by(1)
          expect(response).to have_http_status(204)
        end
      end

      context 'ユーザが存在する場合' do
        context '勤怠ユーザIDが登録されていない場合' do
          before  { User.create(user_id: '', password: '1qaz2wsx', line_user_id: 'U11dcf2ab1d8608c6a') }
          it 'httpステータスコード204を返すこと' do
            post callback_path, params: json_body.to_json
            expect(response).to have_http_status(204)
          end
          it 'ユーザが作成されない' do
            expect {
              post callback_path, params: json_body.to_json
            }.not_to change(User, :count)
          end
        end

        context '勤怠ユーザPWが登録されていない場合' do
          before  { User.create(user_id: '123456789', password: '', line_user_id: 'U11dcf2ab1d8608c6a') }
          it 'httpステータスコード204を返すこと' do
            post callback_path, params: json_body.to_json
            expect(response).to have_http_status(204)
          end
          it 'ユーザが作成されない' do
            expect {
              post callback_path, params: json_body.to_json
            }.not_to change(User, :count)
          end
        end

        context '勤怠ユーザID/PWが登録されている場合' do
          before  { User.create(user_id: '123456789', password: '1qaz2wsx', line_user_id: 'U11dcf2ab1d8608c6a') }
          it 'httpステータスコード204を返すこと' do
            post callback_path, params: json_body.to_json
            expect(response).to have_http_status(204)
          end
          it 'ユーザが作成されない' do
            expect {
              post callback_path, params: json_body.to_json
            }.not_to change(User, :count)
          end
        end
      end
    end
  end
end
