module Bot
  class FlowController
    attr_reader :line_user_id

    def initialize(line_user_id)
      @line_user_id = line_user_id
    end

    def flow(event)
      @memory ||= Rails.cache.read(line_user_id)
      p '----------memory-----------'
      p @memory

      if @memory.blank?
        api_ai = Bot::Flow::Base.parse_intent(event)
        @memory = {
          intent: api_ai[:result], # メッセージをDialogflowにpostし 抽出された意図 ex.'register' or 'show'
          confirmed: {}, # 確認済みのslot
          to_confirme: {}, # 確認するslot
          confirming: nil, # 現在確認中のslot
          verified: {
            confirmed: []
          }
        }
        # "First"
        # 初期状態 1.意図を抽出 2.slotを回収 3.すべてのslotを回収できれば最終解答、出来なければ確認メッセージ返答
        p '----Firest Flow----'
        bot_flow = Bot::Flow::First.new(event, @memory)
        messages = bot_flow.run

      else
        # "Reply"
        # 確認中のslotがある状態 1.メッセージからslotを回収 2.すべてを回収できれば最終解答、出来なければ確認メッセージ返答
        p '----Reply Flow----'
        if @memory[:confirming].present?
          bot_flow = Bot::Flow::Reply.new(event, @memory)
          messages = bot_flow.run

        else
          api_ai = Bot::Flow::Base.parse_intent(event)
          if api_ai.dig(:result, :action) != 'input.unknown'
            @memory[:intent] = api_ai[:result]

            # Change intent
            # 一度、最終返答済みの状態から意図が変更された状態
            # Firstと同様だが、収集したパラメータを継承している
            p '----Change Intent Flow----'
            @memory[:confirmed] = {}
            bot_flow = Bot::Flow::First.new(event, @memory)
            messages = bot_flow.run

          else
            # "Change Slot"
            # 一度、最終返答済みの状態からslotが変更された状態
            # p '----Change Slot Flow----'
            # if @memory[:verified][:confirmed].present?
            #   bot_flow = Bot::Flow::ChangeSlot.new(event, @memory)
            #   messages = bot_flow.run
            #
            # else
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
              p '----Other Flow----'
              bot_flow = Bot::Flow::Other.new(event, @memory)
              messages = bot_flow.run
            # end
          end
        end
      end
      Rails.cache.write(line_user_id, @memory)
      messages
    end
  end
end
