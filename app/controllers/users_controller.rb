class UsersController < ApplicationController

  def new
    @user = User.new()
  end

  def create

    @user = User.new(user_params)
    if @user.save
      flash[:info] = "Please check your email to activate your account."
    else
      render 'edit'
    end
  end

  def edit
    logged_in_user
    current_user
    @user = User.find_by(id: session[:user_id])
  end

  private

  def user_params
    params.require(:user).permit(
      :user_id,
      :password
    )
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def log_in(user)
    session[:user_id] = user.id
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to root_url
      # TODO: LINEからもう一度登録用URLを発行する
    end
  end

  def logged_in?
    !current_user.nil?
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

end
