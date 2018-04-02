require 'line/bot'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  unless Rails.env.development?
    rescue_from StandardError, with: :render_404
    rescue_from Exception, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  def render_404(e = nil)
    logger.error("#{e.class} (#{e.message}):\n#{e.backtrace.join("\n")}") if e
    render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
  end

  def render_500(e = nil)
    logger.error("#{e.class} (#{e.message}):\n#{e.backtrace.join("\n")}") if e
    render file: Rails.root.join('public/500.html'), status: 500, layout: false, content_type: 'text/html'
  end

  def validate_signature
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
