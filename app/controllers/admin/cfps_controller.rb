# frozen_string_literal: true

module Admin
  class CfpsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource through: :program

    def index; end

    def show; end

    def new
      @cfp = @program.cfps.new(cfp_params_or_first_remaining_type)
    end

    def edit; end

    def create
      @cfp = @program.cfps.new(cfp_params)
      send_mail_on_cfp_dates_updates = @cfp.notify_on_cfp_date_update?

      if @cfp.save
        ConferenceCfpUpdateMailJob.perform_later(@conference) if send_mail_on_cfp_dates_updates
        redirect_to admin_conference_program_cfps_path,
                    notice: 'Call for papers successfully created.'
      else
        flash.now[:error] = "Creating the call for papers failed. #{@cfp.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      @cfp.assign_attributes(cfp_params)

      send_mail_on_cfp_dates_updates = @cfp.notify_on_cfp_date_update?

      if @cfp.update(cfp_params)
        ConferenceCfpUpdateMailJob.perform_later(@conference) if send_mail_on_cfp_dates_updates
        redirect_to admin_conference_program_cfps_path(@conference.short_title),
                    notice: 'Call for papers successfully updated.'
      else
        flash.now[:error] = "Updating call for papers failed. #{@cfp.errors.to_a.join('. ')}."
        render :new
      end
    end

    def destroy
      if @cfp.destroy
        redirect_to admin_conference_program_cfps_path, notice: 'Call for Papers was successfully deleted.'
      else
        redirect_to admin_conference_program_cfps_path, error: 'An error prohibited this Call for Papers from being destroyed: '\
        "#{@cfp.errors.full_messages.join('. ')}."
      end
    end

    private

    def cfp_params
      params.require(:cfp).permit(
        :start_date, :end_date,
        :description, :cfp_type,
        :enable_registrations
      )
    end

    def cfp_params_or_first_remaining_type
      cfp_params
    rescue ActionController::ParameterMissing
      { 'cfp_type' => @program.remaining_cfp_types.first }
    end
  end
end
