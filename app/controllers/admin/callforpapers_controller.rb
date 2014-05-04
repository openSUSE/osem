class Admin::CallforpapersController < ApplicationController
  before_filter :verify_organizer

  def index
    @cfp = @conference.call_for_papers
    if @cfp.nil?
      @cfp = CallForPapers.new
      @url = admin_conference_callforpapers_path(@conference.short_title)
    else
      @url = admin_conference_callforpaper_path(@conference.short_title, @cfp)
    end
  end

  def update
    @cfp = @conference.call_for_papers
    if @cfp.update_attributes(params[:call_for_papers])
      redirect_to(admin_conference_callforpapers_path(
                  @conference.short_title),
                  notice: 'Call for Papers was successfully updated.')
    else
      flash.now[:error] = 'Call for Papers update failed. ' + 
	                   @cfp.errors.full_messages.map { |e| e.humanize + '.' }.join(' ')

      @url = admin_conference_callforpaper_path(@conference.short_title, @cfp)
      render action: 'index'
    end
  end

  def create
    @cfp = CallForPapers.new(params[:call_for_papers])
    @cfp.conference_id = @conference.id
    if @cfp.save
      redirect_to(admin_conference_callforpapers_path(
                  @conference.short_title),
                  notice: 'Call for Papers was successfully created.')
    else
      flash.now[:error] = 'Call for Papers creation failed. ' + 
	                   @cfp.errors.full_messages.map { |e| e.humanize + '.' }.join(' ')

      @url = admin_conference_callforpapers_path(@conference.short_title)
      render action: "index"
    end
  end
end
