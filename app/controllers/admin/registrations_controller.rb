class Admin::RegistrationsController < ApplicationController
  before_filter :verify_organizer

  def index
    session[:return_to] ||= request.referer
    @pdf_filename = "#{@conference.title}.pdf"
    @registrations = @conference.registrations.includes(:person).order("registrations.created_at ASC")
    @attended = @conference.registrations.where("attended = ?", true).count
    @headers = %w[first_name last_name email irc_nickname other_needs arrival departure attended]
  end

  def change_field
      @registration = Registration.find(params[:id])
      field = params[:view_field]
      if @registration.send(field.to_sym)
        @registration.update_attribute(:"#{field}",0)
      else
        @registration.update_attribute(:"#{field}",1)
      end

      redirect_to admin_conference_registrations_path(@conference.short_title)
      flash[:notice] = "Updated '#{params[:view_field]}' => #{@registration.attended} for 
                        #{(Person.where("id = ?", @registration.person_id).first).email}"
  end

  def edit
    @registration = @conference.registrations.where("id = ?", params[:id]).first
    @person = Person.where("id = ?", @registration.person_id).first
  end

  def update
    @registration = @conference.registrations.where("id = ?", params[:id]).first
    @person = Person.where("id = ?", @registration.person_id).first
    begin
      @person.update_attributes!(params[:registration][:person_attributes])
      params[:registration].delete :person_attributes
      if params[:registration][:supporter_registration]
        @registration.supporter_registration.update_attributes(params[:registration][:supporter_registration_attributes])
        params[:registration].delete :supporter_registration_attributes
      end
      @registration.update_attributes!(params[:registration])
      flash[:notice] = "Successfully updated registration for #{@person.public_name} #{@person.email}"
      redirect_to(admin_conference_registrations_path(@conference.short_title))
    rescue Exception => e
      Rails.logger.debug e.backtrace.join("\n")
      redirect_to(admin_conference_registrations_path(@conference.short_title), 
                  :alert => 'Failed to update registration:' + e.message)
      return
    end
  end

  def new
    @user = User.new
    @person = Person.new
    @registration = @person.registrations.new
    @supporter_registration = @conference.supporter_registrations.new
    @conference = Conference.find_by(short_title: params[:conference_id])
  end
  
  def create
    @conference = Conference.find_by(short_title: params[:conference_id])
    email = params[:registration][:person].delete(:user)[:email]
    @person = Person.find_by_email email
    @registration = nil
    @user = nil
    
    if @person
      if @person.registrations.where(conference_id: @conference).empty?
        @person.attributes = params[:registration][:person] # Should we really modify person information?
      else
        redirect_to admin_conference_registrations_path(@conference.short_title)
        flash[:notice] = "#{@person.email} is already registred!"
        return
      end
    else
      @person = Person.new params[:registration][:person]
    end
    @person.email = email

    @user = @person.user
    if @user.nil?
      @user = @person.build_user
      @user.password = rand(36**6).to_s(36)
      @user.skip_confirmation!
    end
    @user.email = @person.email

    @registration = @person.registrations.build
    if params[:registration][:supporter_registration]
      @supporter_registration = @registration.build_supporter_registration
      @supporter_registration.attributes = params[:registration][:supporter_registration]
      @supporter_registration.conference_id = @conference.id
    else
      @supporter_registration = @conference.supporter_registrations.new
    end
    params[:registration].delete :person
    params[:registration].delete :user
    params[:registration].delete :supporter_registration
    @registration.attributes = params[:registration]
    @registration.conference_id = @conference.id
    @registration.attended = true
    begin
      Registration.transaction do
        @person.save!
        @user.save!
        @registration.save!
      end
      flash[:notice] = "Successfully created new registration for #{@person.email}."
      redirect_to admin_conference_registrations_path(@conference.short_title)
    rescue ActiveRecord::RecordInvalid
      render action: "new"
    end
  end

  def destroy
    if has_role?(current_user, "Admin")
      registration = @conference.registrations.where(:id => params[:id]).first
      person = Person.where("id = ?", registration.person_id).first
      
      begin registration.destroy
        redirect_to admin_conference_registrations_path
        flash[:notice] = "Deleted registration for #{person.public_name} #{person.email}"
      rescue Exception => e
        Rails.logger.debug e.backtrace.join("\n")
        redirect_to(admin_conference_registrations_path(@conference.short_title), 
	            :alert => 'Failed to delete registration:' + e.message)
        return
      end
    else
      redirect_to(admin_conference_registrations_path(@conference.short_title), 
                  :alert => 'You must be an admin to delete a registration.')
    end
  end
end