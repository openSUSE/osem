class Admin::EmailsController < ApplicationController
  before_filter :verify_organizer

  def update
    @conference.email_settings.update_attributes(params[:email_settings])
    redirect_to(admin_conference_email_settings_path(@conference.short_title), :notice => 'Settings have been successfully updated.')
  end

  def show
    @settings = @conference.email_settings
  end

end
