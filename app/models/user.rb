class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  validates :user_id, presence: true, length: { is: 9 }, on: :update
  validates :password, presence: true, on: :update

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.uuid
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # private

  def create_activation_digest
    self.activation_token = Base64.urlsafe_encode64(User.new_token + self.line_user_id)
    update_attribute(:activation_digest, User.digest(activation_token))
  end

  def update_line_display_name(line_display_name)
    update_columns(line_display_name: line_display_name)
  end
end
