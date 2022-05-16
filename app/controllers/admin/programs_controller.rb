# frozen_string_literal: true

module Admin
  class ProgramsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def show; end

    def edit; end

    def update
      authorize! :update, @conference.program
      @program = @conference.program
      params['program']['languages'] = params['program']['languages'].join(',') if params['program']['languages'].present?
      @program.assign_attributes(program_params)
      send_mail_on_schedule_public = @program.notify_on_schedule_public?
      event_schedules_count_was = @program.event_schedules.count

      if @program.save
        ConferenceScheduleUpdateMailJob.perform_later(@conference) if send_mail_on_schedule_public
        respond_to do |format|
          format.html do
            notice = 'The program was successfully updated.'
            notice += ' You changed schedule interval and some events were unscheduled.' if @program.event_schedules.count != event_schedules_count_was
            redirect_to admin_conference_program_path(@conference.short_title), notice: notice
          end
          format.js { render json: {} }
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:error] = "Updating program failed. #{@program.errors.to_a.join('. ')}."
            render :new
          end
          format.js { render json: { errors: "The selected schedule couldn't be updated #{@program.errors.to_a.join('. ')}" }, status: 422 }
        end
      end
    end

    private

    def program_params
      params.require(:program).permit(:rating, :schedule_public, :schedule_interval, :schedule_fluid, :blind_voting, :voting_start_date, :voting_end_date, :selected_schedule_id, :languages)
    end
  end
end
