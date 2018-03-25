require 'rails_helper'
require 'webmock/rspec'
require 'line/bot'
require_relative '../../../lib/bot/flow_controller'

WebMock.allow_net_connect!

RSpec.describe 'FolowController' do

  let(:memory) do
    # {
    #   intent: api_ai[:result],
    #   confirmed: {},
    #   to_confirme: {},
    #   confirming: nil,
    #   verified {
    #     confirmed: []
    #   }
    # }
  end
  let(:response_headers) do
    { "Content-Type" => "application/json;charset=UTF-8", "Content-Length" => "437", "Connection" => "close", "Access-Control-Allow-Credentials" => "true", "Cache-Control" => "no-cache=\"set-cookie\"", "Date" => "Wed, 12 Oct 2016 20:07:54 GMT", "Server" => "nginx/1.9.7", "Set-Cookie" => "AWSELB=9D5B4D210CCFFAF1BE1E0CD7C7E6FCBD7B46140CAAF64A202A005B9079598B549F7A5EC269DD0FF88508DA57410EFC7882B7860453691E7ACC870186C9D1589D2A332B51EC;PATH=/", "X-Cache" => "Miss from cloudfront", "Via" => "1.1 978198446b6fdba8a499c04f84a3a7e6.cloudfront.net (CloudFront)", "X-Amz-Cf-Id" => "ilwhpG75Ea4iXumklw7484nYt2jbx-L6ZaeiO9naUOstx45ia_nuaQ==" }
  end

  let(:line_request) do
    {
      events: [{
        type: 'message',
        replyToken: '9a68727b1ee34d84a7c1323549dc2cce',
        source: {
          userId: 'U11dcf2ab1d8608c6a',
          type: 'user'
        },
        timestamp: 1521286274866,
        message: {
          type: 'text',
          id: '7639986520165',
          text: '登録する'
        } }],
      webhook: {
        events: [{
          type: 'message',
          replyToken: '9a68727b1ee34d84a7c1323549dc2cce',
          source: {
            userId: 'U11dcf2ab1d8608c6a',
            type: 'user'
          },
          timestamp: 1521286274866,
          message: {
            type: 'text',
            id: '7639986520165',
            text: '登録する'
          }
        }]
      }
    }
  end

  describe 'flow' do
    describe 'First Flow' do
      before { Rails.cache.clear }
      let(:event) do
        line_client = Line::Bot::Client.new
        line_client.parse_events_from(line_request.to_json)[0]
      end

      context 'intentを抽出できた場合' do
        before do
          stub_request(:post, "https://api.api.ai/v1/query?v=20150910").
            to_return(status: 200, body: File.new("#{Rails.root}/spec/fixtures/files/identify_intent_success.json"), headers: response_headers)
        end

        it 'template(始業時間)を返す' do
          messages = Bot::FlowController.new('test123').flow(event)
          expect(messages).to eq(
            {
              type: 'template',
              altText: '始業時間は何時ですか？',
              template: {
                type: 'buttons',
                text: "始業時間は何時ですか？\n当てはまらない場合は4桁の数字でコメントしてね。",
                actions: [
                  { type: 'postback', label: '9:00', data: '0900', displayText: '0900' },
                  { type: 'postback', label: '10:00', data: '1000', displayText: '1000' },
                  { type: 'postback', label: '10:30', data: '1030', displayText: '1030' },
                  { type: 'postback', label: '11:00', data: '1100', displayText: '1100' }
                ]
              }
            }
          )
        end
      end

      context 'intentとparameter(time)を抽出できた場合' do
        before do
          stub_request(:post, "https://api.api.ai/v1/query?v=20150910").
            to_return(status: 200, body: File.new("#{Rails.root}/spec/fixtures/files/identify_intent_parameter1_success.json"), headers: response_headers)
        end

        it 'template(就業時間)を返す' do
          messages = Bot::FlowController.new('test123').flow(event)
          expect(messages).to eq(
            {
              type: 'template',
              altText: '就業時間は何時ですか？',
              template: {
                type: 'buttons',
                text: "就業時間は何時ですか？\n当てはまらない場合は4桁の数字でコメントしてね。",
                actions: [
                  { type: 'postback', label: '17:45', data: '1745', displayText: '1745' },
                  { type: 'postback', label: '19:00', data: '1900', displayText: '1900' },
                  { type: 'postback', label: '19:30', data: '1930', displayText: '1930' },
                  { type: 'postback', label: '20:00', data: '2000', displayText: '2000' }
                ]
              }
            }
          )
        end
      end

      context 'intentとparameter(time, time1)を抽出できた場合' do
        before do
          stub_request(:post, "https://api.api.ai/v1/query?v=20150910").
            to_return(status: 200, body: File.new("#{Rails.root}/spec/fixtures/files/identify_intent_parameters_success.json"), headers: response_headers)

          allow(Register).to receive(:new).and_return(Register.new)
          allow(Register.new).to receive(:create_message).and_return('test_message')
        end
        it '登録メソッドが呼び出される' do
          messages = Bot::FlowController.new('test123').flow(event)
          expect(messages).to eq('test_message')
        end
      end
    end
  end
end
