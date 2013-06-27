class Admin::PeopleController < ApplicationController
  before_filter :verify_organizer

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

  def create

  end

  def show
    @person = Person.find(params[:id])
  end

  def update

  end

  def delete

  end
end
