class Admin::RegistrationsController < ApplicationController
  before_filter :verify_organizer

  def show
    session[:return_to] ||= request.referer
    @pdf_filename = "#{@conference.title}.pdf"
    @registrations = @conference.registrations.all(:joins => :person,
                                                   :order => "people.last_name ASC",
                                                   :select => "registrations.*,
                                                               people.last_name AS last_name,
                                                               people.first_name AS first_name,
                                                               people.public_name AS public_name,
                                                               people.email AS email")
  end
end