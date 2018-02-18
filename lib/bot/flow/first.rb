module Bot
  module Flow
    class First < Base
      def run
        if !@memory.dig(:intent, :parameters).nil? && @memory.dig(:intent, :parameters).values[0].present?
          @memory.dig(:intent, :parameters).each_key do |key|
            filtering_slot(key, @memory.dig(:intent, :parameters, key))
          end
        end

       create_message
      end
    end
  end
end
