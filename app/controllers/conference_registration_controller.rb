class ConferenceRegistrationController < ApplicationController
  before_filter :verify_user

  def register
    # TODO Figure out how to change the route's id from :id to :conference_id
    @conference = Conference.find_all_by_short_title(params[:id]).first
    @person = current_user.person
    @registration = @person.registrations.where(:conference_id => @conference.id).first
    @registered = true
    if @registration.nil?
      @registered = false
      @registration = @person.registrations.new(:conference_id => @conference.id)
    end
  end

  # TODO this is ugly
  def update
    conference = Conference.find_all_by_short_title(params[:id]).first
    person = current_user.person
    registration = person.registrations.where(:conference_id => conference.id).first
    update_registration = true
    begin
      if registration.nil?
        update_registration = false
        person.update_attributes(params[:registration][:person_attributes])
        params[:registration].delete :person_attributes
        registration = person.registrations.new(params[:registration])
        registration.conference_id = conference.id
        registration.save!
      else
        registration.update_attributes!(params[:registration])
      end
    rescue Exception => e
      redirect_to(register_conference_path(:id => conference.short_title), :alert => 'Registration failed:' + e.message)
      return
    end

    redirect_message = "You are now registered."
    if update_registration
      redirect_message = "Registration updated."
    else
      Mailbot.registration_mail(request.host_with_port, conference, current_user.person).deliver
    end
    redirect_to(register_conference_path(:id => conference.short_title), :notice => redirect_message)
  end

  def unregister
    conference = Conference.find_all_by_short_title(params[:id]).first
    person = current_user.person
    registration = person.registrations.where(:conference_id => conference.id).first
    registration.destroy
    redirect_to :root
  end
end
