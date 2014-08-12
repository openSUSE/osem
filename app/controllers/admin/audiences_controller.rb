module Admin
  class AudiencesController < ApplicationController
    before_action :set_conference, only: [:edit, :update]
    before_action :set_audience, only: [:edit, :update]

    def edit
    end

    def update
      @audience.assign_attributes(audience_params)

      notify_on_conf_reg_dates_updates = (@audience.registration_start_date_changed? || @audience.registration_end_date_changed?)\
                                         && @conference.email_settings.send_on_updated_conference_registration_dates\
                                         && !@conference.email_settings.updated_conference_registration_dates_subject.blank?\
                                         && @conference.email_settings.updated_conference_registration_dates_template

      if @audience.update(audience_params)
        Mailbot.delay.conference_registration_date_update_mail(@conference) if notify_on_conf_reg_dates_updates
        redirect_to edit_admin_conference_audience_path(@conference.short_title),
                    notice: 'Audience was successfully updated.'
      else
        render :edit
      end
    end

    private

    def set_conference
      @conference = Conference.find_by(short_title: params[:conference_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_audience
      @audience = @conference.audience
    end

    # Only allow a trusted parameter "white list" through.
    def audience_params
      # params.require(:audience).permit(:conference_id,
      #                                  :registration_start_date,
      #                                  :registration_end_date,
      #                                  :registration_description)
      params[:audience]
    end
  end
end
