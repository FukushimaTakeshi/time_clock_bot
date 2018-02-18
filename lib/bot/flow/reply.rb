module Bot
  module Flow
    class Reply < Base
      def run
        p 'Reply START'
        if @line_event['type'] == 'message'
          text = @line_event['message']['text']
        elsif @line_event['type'] == 'postback'
          text = @line_event['postback']['data']
        end
        filtering_slot(@memory[:confirming], text)

        create_message
      end
    end
  end
end
