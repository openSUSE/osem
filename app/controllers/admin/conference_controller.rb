class Admin::ConferenceController < ApplicationController
  before_filter :verify_organizer

  def index
    @conferences = Conference.all
    if @conferences.count == 0
      redirect_to new_admin_conference_path
      return
    end
  end

  def new
    @conference = Conference.new
  end

  def create
    @conference = Conference.new(params[:conference])
    if @conference.save
      redirect_to(admin_conference_path(:id => @conference.short_title), :notice => 'Conference was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @conference = Conference.find_by(short_title: params[:id])
    short_title = @conference.short_title
    if @conference.update_attributes(params[:conference])
      redirect_to(admin_conference_path(id: @conference.short_title), notice: 'Conference was successfully updated.')
    else
      redirect_to(admin_conference_path(id: short_title), notice: 'Conference update failed.')
    end
  end

  def show
    @conferences = Conference.all
    @conference = Conference.find_by(short_title: params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @conference.to_json }
    end
  end
end
