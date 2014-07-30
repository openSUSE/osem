module Admin
  class RegistrationsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

    def index
      session[:return_to] ||= request.referer
      @pdf_filename = "#{@conference.title}.pdf"
      @registrations = @conference.registrations.includes(:user)
      @registrations = @registrations.order('registrations.created_at ASC')
      @attended = @conference.registrations.where('attended = ?', true).count
      @headers = %w(name email nickname other_needs arrival departure attended)
    end

    def change_field
      field = params[:view_field]
      if @registration.send(field.to_sym)
        @registration.update_attribute(:"#{field}", 0)
      else
        @registration.update_attribute(:"#{field}", 1)
      end

      redirect_to admin_conference_registrations_path(@conference.short_title)
      flash[:notice] = "Updated '#{params[:view_field]}' => #{@registration.attended} for
                        #{(User.where('id = ?', @registration.user_id).first).email}"
    end

    def edit
      @user = User.where('id = ?', @registration.user_id).first
    end

    def update
      @user = User.where('id = ?', @registration.user_id).first
      begin
        @user.update_attributes!(params[:registration][:user_attributes])
        params[:registration].delete :user_attributes
        if params[:registration][:supporter_registration]
          @registration.supporter_registration.
          update_attributes(params[:registration][:supporter_registration_attributes])
          params[:registration].delete :supporter_registration_attributes
        end
        @registration.update_attributes!(params[:registration])
        flash[:success] = "Successfully updated registration for #{@user.name} #{@user.email}"
        redirect_to(admin_conference_registrations_path(@conference.short_title))
      rescue => e
        Rails.logger.debug e.backtrace.join("\n")
        redirect_to(admin_conference_registrations_path(@conference.short_title),
                    alert: 'Failed to update registration:' + e.message)
        return
      end
    end

    def new
      @user = User.new
      @registration = @user.registrations.new
      @registration.conference_id = @conference.id
      @supporter_registration = @conference.supporter_registrations.new
    end

    def create
      @user = User.prepare(user_params['user'])
      @registration = Registration.new

      unless @user.save
        render action: 'new'
        return
      end

      if @conference.user_registered? @user # Check if user is already registered to the conference
        redirect_to admin_conference_registrations_path(@conference.short_title)
        flash[:alert] = "#{@user.email} is already registred!"
        return
      end

      # Build registration
      @registration = @user.registrations.build
      @registration.attributes = registration_params
      @registration.conference_id = @conference.id
      @registration.attended = true

      if params[:registration][:supporter_registration]
        @supporter_registration = @registration.build_supporter_registration
        @supporter_registration.attributes = supporter_params['supporter_registration']
        @supporter_registration.conference_id = @conference.id
      else
        # If we render action: 'new' we need the @supporter_registration variable to be set
        @supporter_registration = @conference.supporter_registrations.new
      end

      if @registration.save
        flash[:success] = "Successfully created new registration for #{@user.email}."
        redirect_to admin_conference_registrations_path(@conference.short_title)
      else
        render action: 'new'
      end
    end

    def destroy
      if can? :destroy, @registration
        registration = @conference.registrations.where(id: params[:id]).first
        user = User.where('id = ?', registration.user_id).first

        begin registration.destroy
          redirect_to admin_conference_registrations_path
          flash[:notice] = "Deleted registration for #{user.name} #{user.email}"
        rescue => e
          Rails.logger.debug e.backtrace.join("\n")
          redirect_to(admin_conference_registrations_path(@conference.short_title),
                      alert: 'Failed to delete registration:' + e.message)
          return
        end
      else
        redirect_to(admin_conference_registrations_path(@conference.short_title),
                    alert: 'You must be an admin to delete a registration.')
      end
    end

    protected

    def registration_params
      params.require(:registration).permit(:attending_with_partner, :using_affiliated_lodging,
                                           :handicapped_access_required, :other_special_needs,
                                           :attended)
    end

    def user_params
      params.require(:registration).permit(user: [:email, :name, :nickname, :affiliation])
    end

    def supporter_params
      params.require(:registration).permit(supporter_registration: [:supporter_level_id, :code])
    end
  end
end
