# frozen_string_literal: true

module Admin
  class RolesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    before_action :set_selection
    authorize_resource :role, except: :index
    # Show flash message with ajax calls
    after_action :prepare_unobtrusive_flash, only: :toggle_user

    def index
      @roles = Role.where(resource: @conference)
      tracks = @conference.program.tracks.where.not(submitter: nil)
      @roles += Role.where(resource: tracks)
      authorize! :index, @role
    end

    def show
      @url = if @track
               toggle_user_admin_conference_program_track_role_path(@conference.short_title, @track, @role.name)
             else
               toggle_user_admin_conference_role_path(@conference.short_title, @role.name)
             end
      @users = @role.users
    end

    def edit
      @url = if @track
               admin_conference_program_track_role_path(@conference.short_title, @track, @role.name)
             else
               admin_conference_role_path(@conference.short_title, @role.name)
             end
      @users = @role.users
    end

    def update
      role_name = @role.name

      if @role.update_attributes(role_params)
        url = if @track
                admin_conference_program_track_role_path(@conference.short_title, @track, @role.name)
              else
                admin_conference_role_path(@conference.short_title, @role.name)
              end

        redirect_to url,
                    notice: 'Successfully updated role ' + @role.name
      else
        @role.name = role_name
        flash.now[:error] = 'Could not update role! ' + @role.errors.full_messages.to_sentence
        render :edit
      end
    end

    def toggle_user
      user = User.find_by(email: user_params[:email])
      state = user_params[:state]

      url = if @track
              admin_conference_program_track_role_path(@conference.short_title, @track, @role.name)
            else
              admin_conference_role_path(@conference.short_title, @role.name)
            end

      unless user
        redirect_to url,
                    error: 'Could not find user. Please provide a valid email!'
        return
      end

      # The conference must have at least 1 organizer
      if @role.name == 'organizer' && state == 'false' && @role.users.count == 1
        redirect_to admin_conference_role_path(@conference.short_title, @role.name),
                    error: 'The conference must have at least 1 organizer!'
        return
      end

      if @role.resource_type == 'Conference'
        role_resource = @conference
      elsif @role.resource_type == 'Track'
        role_resource = @track
      end

      # Remove user
      if state == 'false'
        if user.remove_role @role.name, role_resource
          flash[:notice] = "Successfully removed role #{@role.name} from user #{user.email}"
        else
          flash[:error] = "Could not remove role #{@role.name} from user #{user.email}"
        end
      elsif user.has_cached_role? @role.name, role_resource
        flash[:error] = "User #{user.email} already has the role #{@role.name}"
        # Add user
      elsif user.add_role @role.name, role_resource
        flash[:notice] = "Successfully added role #{@role.name} to user #{user.email}"
      else
        flash[:error] = "Coud not add role #{@role.name} to #{user.email}"
      end

      respond_to do |format|
        format.js
        format.html { redirect_to url }
      end
    end

    protected

    def set_selection
      # Set 'organizer' as default role, when there is no other selection
      @selection = params[:id] ? params[:id].parameterize.underscore : 'organizer'

      if @selection == 'track_organizer'
        @track = @conference.program.tracks.find_by(short_name: params[:track_id])
        @role = Role.find_by(name: @selection, resource: @track)
      else
        @role = Role.find_by(name: @selection, resource: @conference)
      end
    end

    def role_params
      params.require(:role).permit(:name, :description, user_ids: [])
    end

    def user_params
      params.require(:user).permit(:email, :state)
    end
  end
end
