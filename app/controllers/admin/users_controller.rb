module Admin
  class UsersController < Admin::BaseController
    load_and_authorize_resource

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      @user.password = Devise.friendly_token[0, 20]
      @user.username = @user.email.split('@')[0]
      @user.skip_confirmation!
      if @user.save
        redirect_to admin_users_path, notice: "User created. Name: #{@user.name}, email: #{@user.email}"
      else
        flash[:error] = "An error prohibited this user from being saved: #{@user.errors.full_messages.join('. ')}."
        render :new
      end
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
      @user.destroy
      redirect_to admin_users_path, notice: 'User got deleted'
    end

    private

    # Only allow a trusted parameter "white list" through.
    def user_params
      # params.require(:user).permit(:email, :name, :affiliation, :biography)
      params[:user]
    end
  end
end
