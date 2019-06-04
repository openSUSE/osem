module Invitation
  extend ActiveSupport::Concern

  def booth_responsible_invite
    if booth_params[:invite_responsible]
      emails_array = booth_params[:invite_responsible].split(',')

      emails_array.each do |email|
        new_user = User.find_by(email: email)
        if new_user.nil?
          User.invite!({ email: email }, current_user)
          new_user = User.find_by(email: email)
        end
        if new_user && @booth.responsible_ids.exclude?(new_user.id)
          BoothRequest.create(booth_id: @booth.id, user_id: new_user.id,
                              role: 'responsible')
        end
      end
    end
  end
end
