class SurveysController < ApplicationController
  load_resource :conference, find_by: :short_title
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
    @survey_submission = @survey.survey_submissions.new
  end

  def reply
    redirect_to :back
  end

end
