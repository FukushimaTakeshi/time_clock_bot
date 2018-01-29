class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(line_user_id: params[:id])
    # if user && !user.activated? && user.authenticated?(params[:token])
    if user && user.authenticated?(params[:token]) # テスト用 あとで削除
      user.activate
      remember(user)
      log_in user
      flash[:success] = "Account activated!"
      # redirect_to user_url
      redirect_to controller: :users, action: :edit
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

  private

  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    # user.remember
    cookies.permanent.signed[:user_id] = user.id
    # cookies.permanent[:remember_token] = user.remember_token
  end

end
