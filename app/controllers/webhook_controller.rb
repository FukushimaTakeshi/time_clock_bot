class WebhookController < ApplicationController
  protect_from_forgery except: :callback

  def callback
    event = client.parse_events_from(request.body.read)[0]
    logger.info(event)
    line_user_id = event['source']['userId']

    case event
    when Line::Bot::Event::Follow
      # LINEユーザ登録
      follow(line_user_id).create
    when Line::Bot::Event::Unfollow
      # LINEユーザ削除
      unfollow(line_user_id).delete
    else
      user = User.find_by(line_user_id: line_user_id)
      return follow(line_user_id).create if user.nil? # LINEユーザ登録

      if user.user_id.blank? || user.password.blank?
        # 勤怠ユーザ登録
        messages = user_activation_message(line_user_id)
      else
        # LINEユーザ & 勤怠ユーザ登録済み
        # flowの実行
        messages = bot(line_user_id).flow(event)
      end
    end
    response = client.reply_message(event['replyToken'], messages)
    logger.info(response)
  end

  def reminder
    return unless business_day?
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
    users = User.pluck(:line_user_id).uniq
    response = client.multicast(users, message)
    logger.info(response)
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
      text: "こちらのURLからユーザー登録して下さい\n#{edit_account_activation_url(user.activation_token, id: line_user_id, openExternalBrowser: '1')}"
    }
  end

  def business_day?
    today = Date.today
    !(today.wday == 6 || today.wday == 0 || HolidayJp.holiday?(today).present?)
  end
end
