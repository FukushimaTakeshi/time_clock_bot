class AccountActivationsController < ApplicationController
  include UserHandler

  def edit
    user = User.find_by(line_user_id: params[:id])
    # if user && !user.activated? && user.authenticated?(params[:token])
    if user && user.authenticated?(:activation, params[:token]) # テスト用 あとで削除
      user.activate
      remember(user)
      log_in user
      flash[:success] = "Account activated!"
      # redirect_to user_url
      redirect_to controller: :users, action: :new, id: user.id
    else
      # token改ざん or 新しいtokenが発行されている
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

end
