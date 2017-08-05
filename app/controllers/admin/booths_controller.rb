module Admin
  class BoothsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

    def index; end

    def show; end

    def new; end

    def create
      @booth = @conference.booths.new(booth_params)

      @booth.submitter = current_user

      if @booth.save
        redirect_to admin_conference_booths_path,
                    notice: 'Booth successfully created.'
      else
        flash[:error] = "Creating booth failed. #{@booth.errors.full_messages.to_sentence}."
        render :new
      end
    end

    def edit; end

    def update
      @booth.update_attributes(booth_params)

      if @booth.save
        redirect_to admin_conference_booths_path,
                    notice: "Successfully updated booth for #{@booth.title}."
      else
        flash[:error] = "An error prohibited the Booth for #{@booth.title} "\
                    "#{@booth.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @booth.destroy
        redirect_to admin_conference_booths_path,
                    notice: 'Booth successfully destroyed.'
      else
        redirect_to admin_conference_booths_path,
                    error: "Booth couldn't be deleted. #{@booth.errors.full_messages.join('. ')}."
      end
    end

    def accept
      update_state(:accept, 'Booth accepted!')
    end

    def to_accept
      update_state(:to_accept, 'Booth to accept')
    end

    def to_reject
      update_state(:to_reject, 'Booth to reject')
    end

    def reject
      update_state(:reject, 'Booth rejected')
    end

    def restart
      update_state(:restart, 'Booth is submitted')
    end

    def cancel
      update_state(:cancel, 'Booth is canceled')
    end

    private

    def update_state(transition, notice)
      alert = @booth.update_state(transition, notice)

      if alert.blank?
        flash[:notice] = notice
        redirect_back_or_to(admin_conference_booths_path(conference_id: @conference.short_title)) && return
      else
        flash[:error] = alert
        return redirect_back_or_to(admin_conference_booths_path(conference_id: @conference.short_title)) && return
      end
    end

    def booth_params
      params.require(:booth).permit(:title, :description, :reasoning, :state, :picture, :conference_id,
                                    :created_at, :updated_at, :submitter_relationship, :website_url, responsible_ids: [])
    end
  end
end
