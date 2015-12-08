module Admin
  class RegistrationPeriodsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def new
      @registration_period = @conference.build_registration_period
    end

    def create
      @registration_period = @conference.build_registration_period(registration_period)
      send_mail_on_reg_update = @conference.notify_on_registration_dates_changed?

      if @registration_period.save
        Mailbot.delay.conference_registration_date_update_mail(@conference) if send_mail_on_reg_update

        flash[:notice] = 'Registration Period successfully updated.'
        redirect_to admin_conference_registration_period_path(@conference.short_title)
      else
        flash[:error] = "An error prohibited the Registration Period from being saved: #{@registration_period.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit
    end

    def show
    end

    def update
      @registration_period.assign_attributes(registration_period)
      send_mail_on_reg_update = @conference.notify_on_registration_dates_changed?

      if @registration_period.update(registration_period)
        Mailbot.delay.conference_registration_date_update_mail(@conference) if send_mail_on_reg_update

        flash[:notice] = 'Registration Period successfully updated.'
        redirect_to admin_conference_registration_period_path(@conference.short_title)
      else
        flash[:error] = 'An error prohibited the Registration Period from being saved: ' \
                        "#{@registration_period.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      @registration_period.destroy

      flash[:notice] = 'Registration Period was successfully destroyed.'
      redirect_to admin_conference_registration_period_path
    end

    private

    def registration_period
      params[:registration_period]
    end
  end
end
