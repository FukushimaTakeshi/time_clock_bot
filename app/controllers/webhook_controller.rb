class WebhookController < ApplicationController

  def callback

    event = client.parse_events_from(request.body.read)[0]
    # byebug

    case event
    when Line::Bot::Event::Follow
      # TODO:ユーザ登録
      follow(event['source']['userId']).create
    when Line::Bot::Event::Unfollow
      # TODO:ユーザ削除
      unfollow(event['source']['userId']).delete
    # when Line::Bot::Event::Message
    else
      # case event.type
      # when Line::Bot::Event::MessageType::Text
        # TODO:勤怠登録
        p '新規登録'
        messages = flow(event['source']['userId']).flow(event)
      # when Line::Bot::Event::MessageType::Postback
        # TODO:postback
        p 'postbackメッセージ'
        messages = flow(event['source']['userId']).flow(event)
      # end
    # else
      # p 'else'
    end
    # TODO:reply messages
    client.reply_message(event['replyToken'], messages)


    # events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    # }

    "OK"
  end

  private

  def follow(line_user_id)
    Bot::Follow.new(line_user_id)
  end

  def unfollow(line_user_id)
    Bot::Unfollow.new(line_user_id)
  end

  def flow(line_user_id)
    Bot::FlowController.new(line_user_id)
  end
end
