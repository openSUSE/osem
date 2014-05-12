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
    if @conference.valid?
      @conference.save
      redirect_to(admin_conference_path(id: @conference.short_title),
                  notice: 'Conference was successfully created.')
    else
      redirect_to(new_admin_conference_path,
                  flash: { error: @conference.errors.full_messages.join('! ') })
    end
  end

  def update
    @conference = Conference.find_by(short_title: params[:id])
    @conference.update_attributes(params[:conference])
    flash[:notice] = "Updated Conference"
    redirect_to(admin_conference_path(:id => @conference.short_title), :notice => 'Conference was successfully updated.')
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
