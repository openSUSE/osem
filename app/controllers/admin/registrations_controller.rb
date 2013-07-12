class Admin::RegistrationsController < ApplicationController
  before_filter :verify_organizer

  def show
    session[:return_to] ||= request.referer
    @pdf_filename = "#{@conference.title}.pdf"
    @registrations = @conference.registrations.all(:joins => :person,
                                                   :order => "registrations.created_at ASC",
                                                   :select => "registrations.*,
                                                               people.last_name AS last_name,
                                                               people.first_name AS first_name,
                                                               people.public_name AS public_name,
                                                               people.email AS email")

    @attended = @conference.registrations.where("attended = ?", true)
    @headers = %w[attended name email social_events attending_with_partner need_access other_needs arrival departure]
  end

  def change_field
      @registration = Registration.find(params[:id])
      field = params[:view_field]
      if @registration.send(field.to_sym)
        @registration.update_attribute(:"#{field}",0)
      else
        @registration.update_attribute(:"#{field}",1)
      end

      redirect_to admin_conference_registrations_path(@conference.short_title, @registration)
      flash[:notice] = "Updated '#{params[:view_field]}' for #{(Person.where("id = ?", @registration.person_id).first).email}"
  end
end