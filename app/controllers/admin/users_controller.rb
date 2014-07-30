module Admin
  class UsersController < ApplicationController
    load_and_authorize_resource

    def index
      @users = User.all
      @roles = Role.all.where(resource_type: nil)
    end

    def show
      # Variable @show_attributes holds the attributes that are visible for the 'show' action
      # If you want to change the attributes that are shown in the 'show' action of users
      # add/remove the attributes in the following string array
      @show_attributes = %w(name email affiliation biography registered attended roles created_at
                            updated_at sign_in_count current_sign_in_at last_sign_in_at
                            current_sign_in_ip last_sign_in_ip)
    end

    def update
      params[:user].delete :roles_attributes if params[:user]
      @user.update_attributes!(params[:user])
      redirect_to admin_users_path, notice: "Updated #{@user.email}"
    end

    def add_role
      role = params[:user][:roles_attributes][:"0"]
      @user.add_role role['name'].parameterize.underscore.to_sym, Conference.find(role['resource_id'])

      respond_to do |format|
        format.html
        format.js
      end

    end

    def edit
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User #{@user.name} (#{@user.email})got deleted"
    end
  end
end
