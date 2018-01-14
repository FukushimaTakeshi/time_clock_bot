module Bot
  module Flow
    class Other < Base

      def run
        p 'Other START'
        create_message
      end
    end
  end
end
