module Admin
  class ProgramsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def show; end

    def edit; end

    def update
      authorize! :update, @conference.program
      @program = @conference.program
      @program.assign_attributes(params[:program])
#       send_mail_on_schedule_public = @program.notify_on_schedule_public?

      if @program.update_attributes(params[:program])
#         Mailbot.delay.send_on_schedule_public(@conference) if send_mail_on_schedule_public
        redirect_to(admin_conference_program_path(@conference.short_title),
                    notice: 'The program was successfully updated.')
      else
        flash[:error] = "Updating program failed. #{@program.errors.to_a.join('. ')}."
        render :new
      end
    end

    private

    def program_params
      params[:program]
    end
  end
end
