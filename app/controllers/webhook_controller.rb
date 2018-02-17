class WebhookController < ApplicationController

  def callback
    event = client.parse_events_from(request.body.read)[0]
    line_user_id = event['source']['userId']

    case event
    when Line::Bot::Event::Follow
      # ユーザ登録
      follow(line_user_id).create
    when Line::Bot::Event::Unfollow
      # ユーザ削除
      unfollow(line_user_id).delete
    else
      # 登録flow
      user = User.find_by(line_user_id: line_user_id)
      if  user.nil?
        follow(line_user_id).create
        return 'OK'
      elsif user.user_id.blank? || user.password.blank?
        p '新規登録'
        messages = user_activation_message(line_user_id)
      else
        p '登録済み'
        messages = bot(line_user_id).flow(event)
      end
    end
    client.reply_message(event['replyToken'], messages)
  end

  def reminder
    message = {
      type: 'template',
      altText: '前日の勤怠を登録しますか？',
      template: {
        type: 'confirm',
        text: '前日の勤怠を登録しますか？',
        actions: [
          { type: 'message', label: '登録する', text: '登録する' },
          { type: 'message', label: 'やめとく', text: 'やめとく' }
        ]
      }
    }
    user = User.pluck(:line_user_id).uniq
    client.multicast(user, message)
  end

  private

  def follow(line_user_id)
    Bot::Follow.new(line_user_id)
  end

  def unfollow(line_user_id)
    Bot::Unfollow.new(line_user_id)
  end

  def bot(line_user_id)
    Bot::FlowController.new(line_user_id)
  end

  def user_activation_message(line_user_id)
    user = User.find_by(line_user_id: line_user_id)
    user.create_activation_digest
    response = client.get_profile(line_user_id)
    case response
    when Net::HTTPSuccess
      contact = JSON.parse(response.body)
      user.update_line_display_name(contact['displayName'])
    end
    p edit_account_activation_url(user.activation_token, id: line_user_id)
    {
      type: 'text',
      text: "このURLからユーザー登録して下さい\n#{edit_account_activation_url(user.activation_token, id: line_user_id)}"
    }
  end
end
