class Admin::CallforpapersController < ApplicationController
  before_filter :verify_organizer
  layout "admin"

  def show
    @cfp = @conference.call_for_papers
    if @cfp.nil?
      @cfp = CallForPapers.new
    end
  end

  def update
    @cfp = @conference.call_for_papers
    @cfp.update_attributes(params[:call_for_papers])
    redirect_to(admin_conference_cfp_info_path(:id => @conference.short_title), :notice => 'Call for Papers was successfully updated.')

  end

  def create
    @cfp = CallForPapers.new(params[:call_for_papers])
    @conference.call_for_papers = @cfp
    if @cfp.save
      redirect_to(admin_conference_cfp_info_path(:id => @conference.short_title), :notice => 'Call for Papers was successfully updated.')
    else
      redirect_to(admin_conference_cfp_info_path(:id => @conference.short_title), :error => 'Call for Papers failed.')
    end
  end
end
