# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  protected

  def after_confirmation_path_for(_resource_name, resource)
    if signed_in?
      signed_in_root_path(resource)
    else
      sign_in resource
      root_path
    end
  end
end
