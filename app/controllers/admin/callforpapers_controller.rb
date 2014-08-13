module Admin
  class CallforpapersController < ApplicationController
    before_filter :verify_organizer

    def show
      @cfp = @conference.call_for_papers
      if @cfp.nil?
        @cfp = CallForPapers.new
      end
    end

    def update
      @cfp = @conference.call_for_papers
      @cfp.assign_attributes(params[:call_for_papers])
      send_mail_on_schedule_public = @cfp.notify_on_schedule_public?

      send_mail_on_cfp_dates_updates = @cfp.notify_on_cfp_date_update?

      if @cfp.update_attributes(params[:call_for_papers])
        Mailbot.delay.send_on_call_for_papers_dates_updates(@conference) if send_mail_on_cfp_dates_updates
        Mailbot.delay.send_on_schedule_public(@conference) if send_mail_on_schedule_public
        redirect_to(admin_conference_callforpapers_path(
                    id: @conference.short_title),
                    notice: 'Call for Papers was successfully updated.')
      else
        redirect_to(admin_conference_callforpapers_path(
                    id: @conference.short_title),
                    alert: "Updating call for papers failed. #{@cfp.errors.to_a.join(". ")}.")
      end
    end

    def create
      @cfp = CallForPapers.new(params[:call_for_papers])
      if @cfp.valid?
        @cfp.save
        @conference.call_for_papers = @cfp
        redirect_to(admin_conference_callforpapers_path(
                    id: @conference.short_title),
                    notice: 'Call for Papers was successfully created.')
      else
        redirect_to(admin_conference_callforpapers_path(
                    id: @conference.short_title),
                    alert: "Creating the call for papers failed. #{@cfp.errors.to_a.join(". ")}.")
      end
    end
  end
end
