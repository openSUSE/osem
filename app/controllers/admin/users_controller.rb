class Admin::UsersController < ApplicationController
  before_filter :verify_admin

  def index
    @users = User.all(:joins => :person,
                      :order => "people.last_name ASC",
                      :select => "users.*,
                                  people.last_name AS last_name,
                                  people.first_name AS first_name,
                                  people.public_name AS public_name,
                                  people.email AS email")
  end

  def update
    user = User.find(params[:id])
    user.update_attributes!(params[:user])
    redirect_to admin_users_path, :notice => "Updated #{user.email}"
  end
  
  def new
    @user = User.new
    @person = Person.where("user_id =?", @user.id)
    @conferences = Conference.where("end_date >= ?", Time.now)
    @conference = Conference.find_all_by_short_title(params[:format]).first
  end
  
  def create
    @conference = Conference.find_all_by_short_title(params[:id]).first
    
    if params[:user][:people][:first_name].blank? || params[:user][:people][:last_name].blank?
      redirect_to(:back, :alert => "Please fill in your first and last name before registering.")
      return
    end

    params[:user][:conferences].shift
    if !params[:user][:conferences].empty?
      user = User.new
      user.email = params[:user][:email]
      user.password = params[:user][:password]
      begin
        user.save!
        user.skip_confirmation!
        person = Person.where("user_id = ?", user.id).first
        person.update_attributes(params[:user][:people])
        begin
          params[:user][:conferences].each do |r|
            registration = person.registrations.new(:conference_id => r, :attended => 't')
            registration.save!
          end
          redirect_to admin_conference_registrations_path(@conference.short_title)
          flash[:notice] = "Successfully created new registration for #{person.email}."
          rescue Exception => e
          redirect_to(:back, :alert => "Did not create registration. #{e.message}")
          return
        end
        rescue Exception => e
          redirect_to(:back, :alert => "Did not create new user/person. #{e.message}")
          return
      end
    else
      redirect_to(:back, :alert => "Please select at least one conference to register.")
    end
  end
end