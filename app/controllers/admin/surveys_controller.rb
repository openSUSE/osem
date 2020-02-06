# frozen_string_literal: true

module Admin
  class SurveysController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource

    def index
      @surveys = @conference.surveys + Survey.where(surveyable: @conference.program.events)
    end

    def new
      @survey = Survey.new(survey_params)
      @url = admin_conference_surveys_path(@conference.short_title)
    end

    def create
      @survey = Survey.new(survey_params)
      if @survey.save
        redirect_to new_admin_conference_survey_survey_question_path(@conference.short_title, @survey), notice: 'Successfully created survey'
      else
        redirect_to new_admin_conference_survey_path(@conference.short_title, survey: { surveyable_type: survey_params['surveyable_type'], surveyable_id: survey_params['surveyable_id'] }), error: 'Could not create survey.' + @survey.errors.full_messages.to_sentence
      end
    end

    def edit
      @url = admin_conference_survey_path(@conference.short_title, @survey)
    end

    def update
      if @survey.update_attributes(survey_params)
        redirect_to admin_conference_surveys_path(@conference.short_title)
      else
        @url = admin_conference_survey_path(@conference.short_title, @survey)
        render action: :edit
      end
    end

    def destroy
      @survey.destroy
      redirect_to admin_conference_surveys_path(@conference.short_title)
    end

    private

    def survey_params
      params.require(:survey).permit(:title, :description, :target, :start_date, :end_date, :surveyable_type, :surveyable_id)
    end
  end
end
