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
      @show_attributes = %w(name email username nickname affiliation biography registered attended roles created_at
                            updated_at sign_in_count current_sign_in_at last_sign_in_at
                            current_sign_in_ip last_sign_in_ip)
    end

    def update
      message = ''
      if params[:user] && !params[:user][:email].nil?
        if (new_email = params[:user][:email]) != @user.email
          message = " Confirmation email sent to #{new_email}. The new email needs to be confirmed before it can be used."
        end
      end

      if @user.update_attributes(params[:user])
        flash[:notice] = "Updated #{@user.name} (#{@user.email})!" + message
        redirect_to admin_users_path
      else
        flash[:error] = "Could not update #{@user.name} (#{@user.email}). #{@user.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def edit; end
  end
end
