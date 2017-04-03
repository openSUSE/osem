module Admin
  class CfpsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource through: :program, singleton: true

    def show; end

    def new
      @cfp = @program.build_cfp
    end

    def edit; end

    def create
      @cfp = @program.build_cfp(cfp_params)
      send_mail_on_cfp_dates_updates = @cfp.notify_on_cfp_date_update?

      if @cfp.save
        ConferenceCfpUpdateMailJob.perform_later(@conference) if send_mail_on_cfp_dates_updates
        redirect_to admin_conference_program_cfp_path,
                    notice: 'Call for papers successfully created.'
      else
        flash.now[:error] = "Creating the call for papers failed. #{@cfp.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      @cfp = @program.cfp
      @cfp.assign_attributes(cfp_params)

      send_mail_on_cfp_dates_updates = @cfp.notify_on_cfp_date_update?

      if @cfp.update_attributes(cfp_params)
        ConferenceCfpUpdateMailJob.perform_later(@conference) if send_mail_on_cfp_dates_updates
        redirect_to admin_conference_program_cfp_path(@conference.short_title),
                    notice: 'Call for papers successfully updated.'
      else
        flash.now[:error] = "Updating call for papers failed. #{@cfp.errors.to_a.join('. ')}."
        render :new
      end
    end

    def destroy
      if @cfp.destroy
        redirect_to admin_conference_program_cfp_path, notice: 'Call for Papers was successfully deleted.'
      else
        redirect_to admin_conference_program_cfp_path, error: 'An error prohibited this Call for Papers from being destroyed: '\
        "#{@cfp.errors.full_messages.join('. ')}."
      end
    end

    private

    def cfp_params
      params.require(:cfp).permit(:start_date, :end_date)
    end
  end
end
