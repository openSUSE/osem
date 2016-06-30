class SurveyController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource

  def show
    @survey_submission = @survey.survey_submissions.new
  end

  def reply
  end

end
