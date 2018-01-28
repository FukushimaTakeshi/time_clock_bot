require 'line/bot'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  # before_action :validate_signature

  def validate_signature
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      # config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_secret = "bbd17b43590d2c0576ac704f36c6f10e"
      # config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      config.channel_token = "3++00oPmeZoS1T5P0vZXT79yL0sx+zgJ/tlV0z4d7nssMhN+F2vnYdKP2YCMhVSsl02D67Dq83D8DCfKhXM2F5Hx5pVxJHbi2DZDrjnKFp+J84tCz75q80s00185Q3KcIJKjm0pZ2lhmWXtZ80HXmQdB04t89/1O/w1cDnyilFU="
    }
  end
end
