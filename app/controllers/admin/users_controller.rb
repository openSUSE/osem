# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    load_and_authorize_resource

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      @user.skip_confirmation!
      if @user.save
        redirect_to admin_users_path, notice: 'User successfully created.'
      else
        flash.now[:error] = "Creating User failed: #{@user.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def index
      respond_to do |format|
        format.html
        format.json do
          render json: UserDatatable.new(params, view_context: view_context)
        end
      end
    end

    # This action allow admins to manually toggle confirmation state of another user
    def toggle_confirmation
      if user_params[:to_confirm] == 'true'
        @user.confirm
      elsif user_params[:to_confirm] == 'false'
        @user.confirmed_at = nil
        @user.save
      end
      head :ok
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

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Updated #{@user.name} (#{@user.email})!" + message
      else
        redirect_to admin_users_path, error: "Could not update #{@user.name} (#{@user.email}). #{@user.errors.full_messages.join('. ')}."
      end
    end

    def edit; end

    def destroy
      if @user.destroy
        redirect_to admin_users_path, notice: "User #{@user.name} (#{@user.email}) was successfully deleted."
      else
        redirect_to admin_users_path, error: "Could not delete user #{@user.name} (#{@user.email}). #{@user.errors.full_messages.join('. ')}."
      end
    end

    def register_user
      conference = Conference.find(params[:conference_id])

      if @user.registrations.exists?(conference: conference)
        redirect_to edit_admin_user_path(@user),
                    error: "User is already registered to #{conference.title}."
      else
        registration = @user.registrations.build(conference: conference)
        registration.accepted_code_of_conduct = true if conference.code_of_conduct.present?

        if registration.save
          redirect_to edit_admin_user_path(@user),
                      notice: "Successfully registered #{@user.name} to #{conference.title}."
        else
          redirect_to edit_admin_user_path(@user),
                      error: "Failed to register user: #{registration.errors.full_messages.join('. ')}."
        end
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_admin_user_path(@user), error: 'Conference not found.'
    end

    def unregister_user
      registration = @user.registrations.find(params[:registration_id])
      conference_title = registration.conference.title

      if registration.destroy
        redirect_to edit_admin_user_path(@user),
                    notice: "Successfully removed #{@user.name} from #{conference_title}."
      else
        redirect_to edit_admin_user_path(@user),
                    error: "Failed to remove registration: #{registration.errors.full_messages.join('. ')}."
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_admin_user_path(@user), error: 'Registration not found.'
    end

    private

    def user_params
      params.require(:user).permit(:email, :name, :email_public, :biography, :nickname, :affiliation, :is_admin,
                                   :username, :login, :is_disabled, :tshirt, :mobile, :volunteer_experience,
                                   :languages, :to_confirm, :password, role_ids: [])
    end
  end
end
