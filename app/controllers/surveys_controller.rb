# frozen_string_literal: true

class SurveysController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource except: :reply
  load_resource only: :reply
  skip_authorization_check only: :reply

  def index
    @surveys = @conference.surveys.select(&:active?)
  end

  def show
    @survey_submission = @survey.survey_submissions.new
  end

  def reply
    unless can? :reply, @survey
      redirect_to conference_survey_path(@conference, @survey), alert: 'This survey is currently closed'
      return
    end

    survey_submission = params[:survey_submission]

    @survey.survey_questions.each do |survey_question|
      reply = survey_question.survey_replies.find_by(user: current_user)
      reply_text = survey_submission[survey_question.id.to_s].reject(&:blank?).join(',')

      if reply
        reply.update(text: reply_text) unless reply.text == reply_text
      else
        survey_question.survey_replies.create!(text: reply_text, user: current_user)
      end

      user_survey_submission = @survey.survey_submissions.find_by(user: current_user)
      if user_survey_submission
        user_survey_submission.update_attribute(:updated_at, Time.current)
      else
        @survey.survey_submissions.create!(user: current_user)
      end
    end

    redirect_back(fallback_location: root_path, notice: 'Successfully responded to survey.')
  end
end
