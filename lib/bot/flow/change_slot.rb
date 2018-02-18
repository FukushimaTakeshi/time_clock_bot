module Bot
  module Flow
    class ChangeSlot < Base
      def run
        if @line_event['type'] == 'message'
          text = @line_event['message']['text']
        elsif @line_event['type'] == 'postback'
          text = @line_event['postback']['data']
        end

        for key in @memory[:verified][:confirmed] do
          break if ret = filtering_slot(key, text, true)
        end
        messages = [{type: 'text', text: 'わかりませんでした。表現を変えてみて下さい。'}]
        return messages unless ret

        create_message
      end
    end
  end
end
