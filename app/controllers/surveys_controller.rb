class SurveysController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource

  def index
    @surveys = @conference.surveys.select(&:active?)
  end

  def show
    @survey_submission = @survey.survey_submissions.new
  end

  def reply
    survey_submission = params[:survey_submission]

    @survey.survey_questions.each do |survey_question|
      reply = survey_question.survey_replies.find_by(user: current_user)
      reply_text = survey_submission[survey_question.id.to_s].reject(&:blank?).join(',')

      if reply
        reply.update_attributes(text: reply_text) unless reply.text == reply_text
      else
        survey_question.survey_replies.create!(text: reply_text, user: current_user)
      end
      @survey.survey_submissions.create!(user: current_user) unless @survey.survey_submissions.find_by(user: current_user)
    end

    redirect_to :back
  end
end
