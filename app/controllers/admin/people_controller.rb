class Admin::PeopleController < ApplicationController
  before_filter :verify_organizer
  layout "admin"

  def index
    @people = Person.all
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
