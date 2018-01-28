module Bot
  class FlowController
    attr_reader :line_user_id

    def initialize(line_user_id)
      @line_user_id = line_user_id
    end

    def flow(event)
      @memory ||= Rails.cache.read(line_user_id)
      # @memory ||= JSON.parse(Redis.current.get(line_user_id), symbolize_names: true) rescue nil
      p '----------memory-----------'
      p @memory

      if @memory.blank?
        parsed_intent = Bot::Flow::Base.parse_intent(event)
        @memory = {
          intent: parsed_intent[:result], # メッセージをDialogflowにpostし 抽出された意図 ex.'register' or 'show'
          confirmed: {}, # 確認済みのslot
          to_confirme: {}, # 確認するslot
          confirming: nil, # 現在確認中のslot
          verified: {
            confirmed: []
          }
        }
        # "First"
        # 初期状態 1.意図を抽出 2.slotを回収 3.すべてのslotを回収できれば最終解答、出来なければ確認メッセージ返答
        bot_flow = Bot::Flow::First.new(event, @memory)
        messages = bot_flow.run

      else
        # "Reply"
        # 確認中のslotがある状態 1.メッセージからslotを回収 2.すべてを回収できれば最終解答、出来なければ確認メッセージ返答
        if @memory[:confirming].present?
          bot_flow = Bot::Flow::Reply.new(event, @memory)
          messages = bot_flow.run

        else
          apiAi = Bot::Flow::Base.parse_intent(event)
          if apiAi.dig(:result, :action) != 'input.unknown'
            @memory[:intent] = apiAi[:result]

            # Change intent
            # 一度、最終返答済みの状態から意図が変更された状態
            # Firstと同様だが、収集したパラメータを継承している
            bot_flow = Bot::Flow::First.new(event, @memory)
            messages = bot_flow.run

          else
            # "Change Slot"
            # 一度、最終返答済みの状態からslotが変更された状態
            if @memory[:verified][:confirmed].present?
              bot_flow = Bot::Flow::ChangeSlot.new(event, @memory)
              messages = bot_flow.run

            else
              # "Other"
              # 一度、最終返答済みであが、上記のflowのどれにも当てはまらない場合
              @memory = {
                intent: apiAi[:result],
                confirmed: {},
                to_confirme: {},
                confirming: nil,
                verified: {
                  confirmed: []
                }
              }
              bot_flow = Bot::Flow::Other.new(event, @memory)
              messages = bot_flow.run
            end
          end
        end
      end
      Rails.cache.write(line_user_id, @memory, expired_in: 30.seconds)
      # Redis.current.setex(line_user_id, 30, @memory.to_json)
      messages
    end
  end
end
