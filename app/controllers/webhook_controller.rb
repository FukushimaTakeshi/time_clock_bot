class WebhookController < ApplicationController

  def callback

    event = client.parse_events_from(request.body.read)[0]
    # byebug
    line_user_id = event['source']['userId']

    case event
    when Line::Bot::Event::Follow
      # TODO:ユーザ登録
      follow(line_user_id).create
      # user = User.find_by(line_user_id: line_user_id)
      # user.create_activation_digest
      # messages = {
      #   type: 'text',
      #   text: "このURLからユーザー登録して下さい\n#{edit_account_activation_url(user.activation_token, id: line_user_id)}"
      # }

    when Line::Bot::Event::Unfollow
      # TODO:ユーザ削除
      unfollow(line_user_id).delete

    # when Line::Bot::Event::Message
    else
      # case event.type
      # when Line::Bot::Event::MessageType::Text
        # TODO:勤怠登録
        user = User.find_by(line_user_id: line_user_id)
        if user.user_id || user.password
          P '登録済み'
          messages = flow(line_user_id).flow(event)
        else
          p '新規登録'
          user.create_activation_digest
          messages = {
            type: 'text',
            text: "このURLからユーザー登録して下さい\n#{edit_account_activation_url(user.activation_token, id: line_user_id)}"
          }

        end
      # when Line::Bot::Event::MessageType::Postback
        # TODO:postback
        # messages = flow(line_user_id).flow(event)
      # end
    # else
      # p 'else'
    end
    # TODO:reply messages
    client.reply_message(event['replyToken'], messages)
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
