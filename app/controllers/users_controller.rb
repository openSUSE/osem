# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :load_user
  load_and_authorize_resource

  # GET /users/1
  def show
    @events = @user.events.where(state: :confirmed)
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      flash.now[:error] = "An error prohibited your Profile from being saved: #{@user.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :biography, :nickname, :affiliation,
                                  :picture, :picture_cache)
  end

  # Somewhat of a hack: users/current/edit
  def load_user
    @user ||= (params[:id] && params[:id] != 'current' && User.find(params[:id]) || current_user)
  end
end
