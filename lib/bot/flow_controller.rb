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
        apiAi = Bot::Flow::Base.parse_intent(event)
        @memory = {
          intent: apiAi[:result],
          confirmed: {},
          to_confirme: {},
          confirming: nil,
          verified: {
            confirmed: []
          }
        }
        # "First"
        bot_flow = Bot::Flow::First.new(event, @memory)
        messages = bot_flow.run

      else  # "Reply"
        if @memory[:confirming].present?
          bot_flow = Bot::Flow::Reply.new(event, @memory)
          messages = bot_flow.run

        else
          apiAi = Bot::Flow::Base.parse_intent(event)
          if apiAi.dig(:result, :action) != 'input.unknown'
            @memory[:intent] = apiAi[:result]
            # "First"
            bot_flow = Bot::Flow::First.new(event, @memory)
            messages = bot_flow.run

          else # "Change Slot"
            if @memory[:verified][:confirmed].present?
              bot_flow = Bot::Flow::ChangeSlot.new(event, @memory)
              messages = bot_flow.run

            else # "Other"
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
      # 'memory regist'
      p 'cache write!!!'
      p Rails.cache.write(line_user_id, @memory, expired_in: 30.seconds)
      # Redis.current.setex(line_user_id, 30, @memory.to_json)
      messages
    end
  end
end
