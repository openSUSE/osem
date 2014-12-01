module Admin
  class CallForPapersController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def show; end

    def new
      @call_for_paper = @conference.build_call_for_paper
    end

    def edit; end

    def create
      @call_for_paper = @conference.build_call_for_paper(call_for_paper_params)

      if @call_for_paper.save
        redirect_to admin_conference_call_for_paper_path,
                    notice: 'Call for papers successfully created.'
      else
        flash[:error] = "Creating the call for papers failed. #{@call_for_paper.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      authorize! :update, @conference.call_for_paper
      @cfp = @conference.call_for_paper
      @cfp.assign_attributes(params[:call_for_paper])
      send_mail_on_schedule_public = @cfp.notify_on_schedule_public?

      send_mail_on_cfp_dates_updates = @cfp.notify_on_cfp_date_update?

      if @cfp.update_attributes(params[:call_for_paper])
        Mailbot.delay.send_on_call_for_papers_dates_updates(@conference) if send_mail_on_cfp_dates_updates
        Mailbot.delay.send_on_schedule_public(@conference) if send_mail_on_schedule_public
        redirect_to(admin_conference_call_for_paper_path(@conference.short_title),
                    notice: 'Call for papers successfully updated.')
      else
        flash[:error] = "Updating call for papers failed. #{@cfp.errors.to_a.join('. ')}."
        render :new
      end
    end

    def destroy
      if @call_for_paper.destroy
        redirect_to admin_conference_call_for_paper_path, notice: 'Call for Papers was successfully deleted.'
      else
        redirect_to admin_conference_call_for_paper_path, error: 'An error prohibited this Call for Papers from being destroyed: '\
        "#{@call_for_paper.errors.full_messages.join('. ')}."
      end
    end

    private

    def call_for_paper_params
      params[:call_for_paper]
    end
  end
end
