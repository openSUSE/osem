module Admin
  class UsersController < ApplicationController
    before_filter :verify_admin

    def index
      @users = User.all
    end

    def show
      @user = User.find(params[:id])

      # Variable @show_attributes holds the attributes that are visible for the 'show' action
      # If you want to change the attributes that are shown in the 'show' action of users
      # add/remove the attributes in the following string array
      @show_attributes = %w(name email affiliation biography registered attended created_at
                            updated_at sign_in_count current_sign_in_at last_sign_in_at
                            current_sign_in_ip last_sign_in_ip)
    end

    def update
      user = User.find(params[:id])
      user.update_attributes!(params[:user])
      redirect_to admin_users_path, notice: "Updated #{user.email}"
    end

    def edit
      @user = User.find(params[:id])
    end

    def delete
      @user = User.find(params[:id])
    end

    def destroy
      @user = User.find(params[:id])
      @user.events.destroy_all
      @user.destroy
      redirect_to admin_users_path, notice: 'User got deleted'
    end
  end
end
