class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def edit
    @openids = Openid.where(user_id: current_user.id).order(:provider)
  end

  def update
    @user = User.find(current_user.id)
    email_changed = false

    if !params[:user][:email].nil?
      if @user.email != params[:user][:email]
        email_changed = true
      else
        params[:user].delete :email
      end
    end

    password_changed = false
    if !params[:user][:password].nil?
      if !params[:user][:password].empty?
          password_changed = true
      else
        params[:user].delete :password
        params[:user].delete :password_confirmation
      end
    end

    if email_changed or password_changed
      successfully_updated = @user.update_with_password(account_update_params)
    else
      params[:user].delete :current_password
      successfully_updated = @user.update_without_password(account_update_params)
    end

    if successfully_updated
      if email_changed
        if !@user.person.nil?
          @user.person.update_attribute("email", params[:user][:email])
        end
        set_flash_message :notice, :update_needs_confirmation
      else
        set_flash_message :notice, :updated
      end
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      flash[:alert] = 'Updating account failed. ' \
        "#{@user.errors.full_messages.join('. ')}."
      render 'edit'
    end
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path(resource)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.
          permit(:email, :password, :password_confirmation, :current_password,
                 person_attributes: [:id, :email, :first_name, :last_name,
                                     :public_name, :biography, :company, :avatar,
                                     :irc_nickname, :mobile, :tshirt, :languages,
                                     :volunteer_experience])
    end
  end
end
