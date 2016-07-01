class SurveySubmissionsController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_resource :survey
  load_and_authorize_resource
#   skip_before_filter :verify_authenticity_token

  def edit
  end

  def update
  end

  def new
  end

  def update
  end

  def show
  end
end
