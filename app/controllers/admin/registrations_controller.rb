module Admin
  class RegistrationsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :registration, through: :conference
    before_filter :set_user, except: [:index]

    def index
      authorize! :show, Registration.new(conference_id: @conference.id)
      @pdf_filename = "#{@conference.title}.pdf"
      @registrations = @conference.registrations.includes(:user).order('registrations.created_at ASC')
      @attended = @conference.registrations.where('attended = ?', true).count
    end

    def edit; end

    def update
      @registration.update_attributes(registration_params)
      if @registration.save
        redirect_to admin_conference_registrations_path(@conference.short_title),
                    notice: 'Successfully updated registration!'
      else
        flash[:error] = "An error prohibited the Registration for #{@conference.title}: "\
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
        redirect_to(admin_conference_registrations_path(@conference.short_title),
                    error: 'You must be an admin to delete a registration.')
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

    protected

    def set_user
      @user = User.find_by(id: @registration.user_id)
    end

    def registration_params
      params.require(:registration).
          permit(
              :conference_id, :arrival, :departure,
              :volunteer,
              vchoice_ids: [], qanswer_ids: [],
              qanswers_attributes: [],
              user_attributes: [
                  :id, :name, :tshirt, :mobile, :volunteer_experience, :languages,
                  :nickname, :affiliation])
    end
  end
end
