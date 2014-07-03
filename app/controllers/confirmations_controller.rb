class ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if Conference.all.count == 1 && Conference.first.registration_open?
        @conference = Conference.first
        @conference.registrations.create!(user_id: self.resource.id)
        @redirection_path = register_conference_path(@conference.short_title)
    end

    sign_in resource if resource

    if resource.errors.empty?
      if @redirection_path.blank?
        set_flash_message(:notice, :confirmed) if is_flashing_format?
      else
        set_flash_message(:notice, :confirmed_registered) if is_flashing_format?
      end
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) } and return
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new } and return
    end
  end

  private

  def after_confirmation_path_for(resource_name, resource)

    if @redirection_path.blank?
      if signed_in?
        signed_in_root_path(resource)
      else
        new_session_path(resource_name)
      end
    else
      @redirection_path
    end
  end
end
