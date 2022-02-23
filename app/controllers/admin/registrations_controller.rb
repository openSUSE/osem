# frozen_string_literal: true

module Admin
  class RegistrationsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :registration, through: :conference
    before_action :set_user, except: [:index]

    def index
      authorize! :show, Registration.new(conference_id: @conference.id)
      @pdf_filename = "#{@conference.title}.pdf"
      @registrations = @conference.registrations.includes(:user).order('registrations.created_at ASC')
      @attended = @conference.registrations.where('attended = ?', true).count

      @registration_distribution = @conference.registration_distribution
      @affiliation_distribution = @conference.affiliation_distribution
      @code_of_conduct = @conference.code_of_conduct.present?
      @file_name = "registrations_for_#{@conference.short_title}"

      respond_to do |format|
        format.html
        format.json do
          render json: RegistrationDatatable.new({}, conference: @conference, view_context: view_context)
        end
        format.pdf { render 'index', layout: false }
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xlsx\""
          render 'index', layout: false
        end
        format.csv do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.csv\""
          render 'index', layout: false
        end
      end
    end

    def edit; end

    def update
      @user.update(user_params)

      @registration.update(registration_params)
      if @registration.save
        redirect_to admin_conference_registrations_path(@conference.short_title),
                    notice: "Successfully updated registration for #{@registration.user.email}!"
      else
        flash.now[:error] = "An error prohibited the Registration for #{@registration.user.email}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if can? :destroy, @registration
        @registration.destroy
        redirect_to admin_conference_registrations_path(@conference.short_title),
                    notice: "Deleted registration for #{@user.name}!"
      else
        redirect_to admin_conference_registrations_path(@conference.short_title),
                    error: 'You must be an admin to delete a registration.'
      end
    end

    def toggle_attendance
      @registration.attended = !@registration.attended
      if @registration.save
        head :ok
      else
        head :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find_by(id: @registration.user_id)
    end

    def user_params
      params.require(:user).permit(:name, :nickname, :affiliation)
    end

    def registration_params
      params.require(:registration).permit(
        :user_id, :conference_id, :attended,
        :volunteer, :other_special_needs, :accepted_code_of_conduct,
        vchoice_ids: [], qanswer_ids: [], qanswers_attributes: [], event_ids: []
      )
    end
  end
end
