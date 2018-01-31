class UsersController < ApplicationController
  include UserHandler

  before_action :logged_in_user, only: [:show, :new, :update]
  before_action :correct_user, only: [:show, :new, :update]

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
      render 'edit'
    end
  end

  private

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end



end
