# frozen_string_literal: true

module Admin
  class RegistrationPeriodsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def new
      @registration_period = @conference.build_registration_period
    end

    def create
      @registration_period = @conference.build_registration_period(registration_period_params)
      send_mail_on_reg_update = @conference.notify_on_registration_dates_changed?

      if @registration_period.save
        ConferenceRegistrationDateUpdateMailJob.perform_later(@conference) if send_mail_on_reg_update
        redirect_to admin_conference_registration_period_path(@conference.short_title),
                    notice: 'Registration Period successfully updated.'
      else
        flash.now[:error] = "An error prohibited the Registration Period from being saved: #{@registration_period.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      @registration_period.assign_attributes(registration_period_params)
      send_mail_on_reg_update = @conference.notify_on_registration_dates_changed?

      if @registration_period.update(registration_period_params)
        ConferenceRegistrationDateUpdateMailJob.perform_later(@conference) if send_mail_on_reg_update
        redirect_to admin_conference_registration_period_path(@conference.short_title),
                    notice: 'Registration Period successfully updated.'
      else
        flash.now[:error] = 'An error prohibited the Registration Period from being saved: ' \
        "#{@registration_period.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      @registration_period.destroy
      redirect_to admin_conference_registration_period_path,
                  notice: 'Registration Period was successfully destroyed.'
    end

    private

    def registration_period_params
      params.require(:registration_period).permit(:start_date, :end_date)
    end
  end
end
