class OpenidsController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource through: :user

  def destroy
    @openid.destroy
    redirect_to :back
  end
end
