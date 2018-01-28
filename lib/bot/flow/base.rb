module Bot
  module Flow
    class Base
      attr_accessor :line_event, :memory

      def initialize(line_event, memory)
        @line_event = line_event
        @memory = memory

        @bot_plugin = bot_plugin(@memory.dig(:intent, :action))
        @memory[:to_confirme] = confirm_slot(@memory[:confirmed]) if @memory[:to_confirme].values[0].blank?
      end

      def bot_plugin(action)
        p "bot_plugin action : #{action}"
        p "../plugins/#{action}"
        return nil unless action

        action = 'other' if action == 'input.unknown'
        require "#{Rails.application.config.autoload_paths[0].to_s}/bot/plugins/#{action}.rb"
        # classname = "#{action}"
        Object.const_get("#{action}".camelize).new
      end

      def confirm_slot(confirmed)
        to_confirme = {}
        return to_confirme unless @bot_plugin.instance_variable_defined?(:@required_slot)

        # pluginで定義した確認メッセージ(@required_slot)の内、
        # 回収できなかったメッセージをmemory[:to_confirme]にセット
        @bot_plugin.required_slot.each_key do |key|
          to_confirme[key] = @bot_plugin.required_slot[key] if confirmed.blank? || !confirmed.has_key?(key)
        end
        to_confirme
      end

      # メッセージからintentを抽出する
      def self.parse_intent(event)
        text = if event['type'] == 'message'
                 event['message']['text']
               elsif event['type'] == 'postback'
                 event['postback']['data']
               end

        api_ai_ruby = ApiAiRuby::Client.new(
            # client_access_token: ENV["APIAI_CLIENT_ACCESS_TOKEN"],
            client_access_token: "64f4c041499b4fc5b83e6a8fab051426",
            api_lang: 'ja'
        )
        api_ai_ruby.text_request(text)
      end

      # メッセージに含まれるslot(パラメータ)を抽出する
      def filtering_slot(key, value, change_intent = false)
        if @bot_plugin.required_slot.has_key?(key.to_sym)
          parsed_value = if @bot_plugin.respond_to?("parser_#{key}")
                           # 'メソッドあり'
                           @bot_plugin.send("parser_#{key}", value)
                         else
                           # 'メソッドなし'
                           value
                         end
          return false unless parsed_value

          p 'slot filtering'
          param = {}
          param[key.to_sym] = parsed_value
          @memory[:confirmed].merge!(param)
          @memory[:verified][:confirmed] << key unless change_intent
          @memory[:to_confirme].delete(key.to_sym)
          @memory[:confirming] = nil if @memory[:confirming] == key

          true
        end
      end

      def collect_slot
        @memory[:confirming] = @memory[:to_confirme].keys[0]
        @memory.dig(:to_confirme, @memory[:to_confirme].keys[0], :line_reply_message)
      end

      def create_message
        p '----create_message-------------'
        p @memory[:to_confirme].values[0]
        return collect_slot if @memory[:to_confirme].values[0].present?
        @bot_plugin.create_message(@memory)
      end
    end
  end
end
