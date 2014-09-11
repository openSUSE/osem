module Admin
  class UsersController < Admin::BaseController
    load_and_authorize_resource

    def new
      @user = User.new
    end

    def index
      @users = User.all
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
      if @user.update_attributes(params[:user])
        redirect_to admin_users_path, notice: "Updated #{@user.name} (#{@user.email})!"
      else
        redirect_to admin_users_path, alert: "Could not update #{@user.name} (#{@user.email}). #{@user.errors.full_messages.join('. ')}."
      end
    end

    def edit; end

    def destroy
      sign_out @user
      @user.destroy
      redirect_to admin_users_path, notice: 'User got deleted'
    end
  end
end
