class RegistrationsController < Devise::RegistrationsController
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
        params[:user].delete :current_password
      end
    end


    successfully_updated = if email_changed or password_changed
                             @user.update_with_password(params[:user])
                           else
                             @user.update_without_password(params[:user])
                           end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path(resource)
  end

end