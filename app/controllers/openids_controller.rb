# frozen_string_literal: true

class OpenidsController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource through: :user

  def destroy
    @openid.destroy
    redirect_back(fallback_location: root_path)
  end
end
