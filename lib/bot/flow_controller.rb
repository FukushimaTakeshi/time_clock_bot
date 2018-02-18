module Bot
  class FlowController
    attr_reader :line_user_id

    def initialize(line_user_id)
      @line_user_id = line_user_id
    end

    def flow(event)
      @memory ||= Rails.cache.read(line_user_id)
      Rails.logger.info(@memory)

      if @memory.blank?
        api_ai = Bot::Flow::Base.parse_intent(event)
        @memory = {
          intent: api_ai[:result], # メッセージをDialogflowにpostし 抽出された意図 ex.'register' or 'show'
          confirmed: {}, # 確認済みのslot
          to_confirme: {}, # 確認するslot
          confirming: nil, # 現在確認中のslot
          verified: {
            confirmed: [] # 最終返答済みのslot
          }
        }
        # "First"
        # 初期状態、ここからスタート
        #  1.意図を抽出
        #  2.slotを回収
        #  3.すべてのslotを回収できれば最終解答、出来なければslot回収メッセージ返答
        Rails.logger.info('--Firest Flow--')
        bot_flow = Bot::Flow::First.new(event, @memory)
        messages = bot_flow.run

      else
        if @memory[:confirming].present?
          # "Reply"
          # 確認中のslotがある状態
          #  1.メッセージからslotを回収
          #  2.すべてを回収できれば最終解答、出来なければ確認メッセージ返答
          Rails.logger.info('--Reply Flow--')
          bot_flow = Bot::Flow::Reply.new(event, @memory)
          messages = bot_flow.run

        else
          api_ai = Bot::Flow::Base.parse_intent(event)
          if api_ai.dig(:result, :action) != 'input.unknown'
            @memory[:intent] = api_ai[:result]

            @memory[:confirmed] = {}
            # Change intent
            # 一度、最終返答済みの状態から意図が変更された状態
            # Firstと同様だが、収集したパラメータを継承している
            Rails.logger.info('--Change Intent Flow--')
            bot_flow = Bot::Flow::First.new(event, @memory)
            messages = bot_flow.run

          else
            # "Other"
            # 一度、最終返答済みであが、上記のflowのどれにも当てはまらない場合
            @memory = {
              intent: api_ai[:result],
              confirmed: {},
              to_confirme: {},
              confirming: nil,
              verified: {
                confirmed: []
              }
            }
            Rails.logger.info('--Other Flow--')
            bot_flow = Bot::Flow::Other.new(event, @memory)
            messages = bot_flow.run
          end
        end
      end
      Rails.cache.write(line_user_id, @memory)
      messages
    end
  end
end
