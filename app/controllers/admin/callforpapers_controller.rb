module Admin
  class CallforpapersController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
#     load_and_authorize_resource :call_for_paper, class: 'CallForPapers', through: :conference

    def show
      @cfp = @conference.call_for_papers
      if @cfp.nil?
        @cfp = CallForPapers.new
      end
    end

    def update
      @cfp = @conference.call_for_papers
      @cfp.assign_attributes(params[:call_for_papers])
      notify_on_schedule_public = @cfp.schedule_public_changed? && @cfp.schedule_public\
                                  && @conference.email_settings.send_on_call_for_papers_schedule_public\
                                  && !@conference.email_settings.call_for_papers_schedule_public_subject.blank?\
                                  && !@conference.email_settings.call_for_papers_schedule_public_template.blank?

      notify_on_cfp_date_update = !@cfp.end_date.blank? && !@cfp.start_date.blank?\
                                  && (@cfp.start_date_changed? || @cfp.end_date_changed?)\
                                  && @conference.email_settings.send_on_call_for_papers_dates_updates\
                                  && !@conference.email_settings.call_for_papers_dates_updates_subject.blank?\
                                  && !@conference.email_settings.call_for_papers_dates_updates_template.blank?

      if @cfp.update_attributes(params[:call_for_papers])
        Mailbot.delay.send_on_call_for_papers_dates_updates(@conference) if notify_on_cfp_date_update
        Mailbot.delay.send_on_schedule_public(@conference) if notify_on_schedule_public
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
