require 'rails_helper'
require 'webmock/rspec'
require 'line/bot'
require_relative '../../../lib/bot/flow_controller'

WebMock.allow_net_connect!

RSpec.describe 'FolowController' do

  describe 'flow' do
    let(:api_body) do
      {
        id: '9f071bc4-ae2d-4819-a7d5-f395140a9c53',
        timestamp: '2018-03-22T11:46:21.321Z',
        lang: 'ja',
        result: {
          source: 'agent',
          resolvedQuery: '登録する',
          action: 'register',
          actionIncomplete: false,
          parameters: {
            time: '',
            time1: '',
            Chronus: 'chronus'
          },
          contexts: [],
          metadata: {
            intentId: '9e0cc0e6-38b5-4412-a68e-07356f478a1a',
            webhookUsed: 'false',
            webhookForSlotFillingUsed: 'false',
            intentName: '登録'
          },
          fulfillment: {
            speech: '',
            messages: [
              {
                type: 0,
                speech: ''
              }
            ]
          },
          score: 0.7400000095367432
        },
        status: {
          code: 200,
          errorType: 'success',
          webhookTimedOut: false
        },
        sessionId: 'fc629ed1-20fe-4611-9fe7-1e4a3aeb2214'
      }
    end
    before do
      stub_request(:post, 'https://api.api.ai/v1/').to_return { |request| { body: api_body.to_json, status: 200 } }
    end
    describe 'First Flow' do
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

      let(:line_request) do
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

      before do
        # Rails.cache.write('test123', memory)
      end

      it '' do
        line_client = Line::Bot::Client.new
        event = line_client.parse_events_from(line_request.to_json)[0]
        messages = Bot::FlowController.new('test123').flow(event)
        p messages
        p '--------------------------'
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
          }.to_json
        )
      end
    end
  end
end
