# frozen_string_literal: true

module Admin
  class BoothsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

    def index
      @file_name = "booths_for_#{@conference.short_title}"
      @booth_export_option = params[:booth_export_option]
      respond_to do |format|
        format.html
        # Explicity call #to_json to avoid the use of EventSerializer
        format.json { render json: Booth.where(state: :confirmed, program: @program).to_json }
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xlsx\""
          render 'booths'
        end
        format.pdf { render 'booths' }
        format.csv do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.csv\""
          render 'booths'
        end
      end
    end

    def show; end

    def new
      @url = admin_conference_booths_path(@conference.short_title)
    end

    def create
      @url = admin_conference_booths_path(@conference.short_title)

      @booth = @conference.booths.new(booth_params)

      @booth.submitter = current_user

      if @booth.save
        redirect_to admin_conference_booths_path,
                    notice: 'Booth successfully created.'
      else
        flash.now[:error] = "Creating booth failed. #{@booth.errors.full_messages.to_sentence}."
        render :new
      end
    end

    def edit
      @url = admin_conference_booth_path(@conference.short_title, @booth.id)
    end

    def update
      @url = admin_conference_booth_path(@conference.short_title, @booth.id)

      @booth.update_attributes(booth_params)

      if @booth.save
        redirect_to admin_conference_booths_path,
                    notice: "Successfully updated booth for #{@booth.title}."
      else
        flash.now[:error] = "An error prohibited the Booth for #{@booth.title} "\
                    "#{@booth.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def accept
      @booth.accept!

      if @booth.save
        if @conference.email_settings.send_on_booths_acceptance
          Mailbot.conference_booths_acceptance_mail(@booth).deliver_later
        end
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title),
                    notice: 'Booth successfully accepted!'
      else
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title)
        flash[:error] = "Booth could not be accepted. #{@booth.errors.full_messages.to_sentence}."
      end
    end

    def to_accept
      update_state(:to_accept, 'Booth to accept')
    end

    def to_reject
      update_state(:to_reject, 'Booth to reject')
    end

    def reject
      @booth.reject!

      if @booth.save
        Mailbot.conference_booths_rejection_mail(@booth).deliver_later
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title),
                    notice: 'Booth successfully rejected.'
      else
        redirect_to admin_conference_booths_path(conference_id: @conference.short_title)
        flash[:error] = "Booth could not be rejected. #{@booth.errors.full_messages.to_sentence}."
      end
    end

    def restart
      update_state(:restart, 'Booth is submitted')
    end

    def cancel
      update_state(:cancel, 'Booth is canceled')
    end

    def confirm
      update_state(:confirm, 'Booth successfully confirmed')
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
