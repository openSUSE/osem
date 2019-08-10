module Admin
  class InvitesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title

    def index
      @invites = Invite.where(conference_id: @conference.id)
      @invites.each do |invite|
        invite.emails = User.find(invite.user_id).email
      end
    end

    def new
      @invite = @conference.invites.new
    end

    def create
      emails_array = invite_params[:emails].split(',')
      invite_count = 0
      flag = 0
      emails_array.each do |email|
        @invite = @conference.invites.new(invite_params)
        new_user = User.find_by(email: email)
        new_user = User.invite!({ email: email }, current_user) if new_user.nil?
        @invite.user_id = new_user.id
        invite_count += 1
        unless @invite.save
          flash.now[:error] = "#{(invite_count - 1)} invitations created. Creating invitation failed. #{@invite.errors.full_messages.to_sentence}."
          flag = 1
          break
        end
      end
      if flag.zero?
        redirect_to admin_conference_invites_path, notice: "#{invite_count.to_s + ' invitation'.pluralize(invite_count)} successfully created."
      else
        render 'new'
      end
    end

    def edit
      @invite = Invite.find(params[:id])
    end

    def update
      @invite = Invite.find(params[:id])
      if @invite.update_attributes(invite_params)
        redirect_to admin_conference_invites_path,
                    notice: 'Invitation successfully updated.'
      else
        flash.now[:error] = "Creating invitation failed. #{@invite.errors.full_messages.to_sentence}."
        render 'edit'
      end
    end

    def destroy
      if Invite.find(params[:id]).destroy
        redirect_to admin_conference_invites_path,
                    notice: 'Invitation deleted.'
      else
        redirect_to admin_conference_invites_path,
                    notice: 'Unable to delete the invitation.'
      end
    end

    private

    def invite_params
      params.require(:invite).permit(:emails, :end_date, :invite_for)
    end
  end
end
