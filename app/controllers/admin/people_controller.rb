class Admin::PeopleController < ApplicationController
  before_filter :verify_organizer
  respond_to :html

  def index
    @people = Person.all
    mails = []
    @people.each do |p|
      if p.registrations.count < 1 and p.confirmed?
        mails << p.email
     end
    end
    respond_to do |format|
      format.html
      format.text { render :text => mails }
    end
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    flash[:notice] = 'Person was successfully created.' if @person.save
    respond_with @person, :location => admin_people_path
  end

  def show
    @person = Person.find(params[:id])
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    flash[:notice] = 'Person was successfully updated' if @person.update_attributes(params[:person])
    respond_with @person, :location => admin_people_path
  end

  def delete

  end
end
