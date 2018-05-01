# frozen_string_literal: true

module Api
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception
  end
end
