class UsersController < ApplicationController
  include UserHandler

  before_action :logged_in_user
  before_action :correct_user

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'new'
    end
  end

  def destroy
    forget
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to root_url
  end

  private

  def user_params
    params.require(:user).permit(
      :user_id,
      :password
    )
  end

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
