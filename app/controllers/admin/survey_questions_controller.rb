# frozen_string_literal: true

module Admin
  class SurveyQuestionsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :survey
    load_and_authorize_resource through: :survey

    def new
      @survey_question = @survey.survey_questions.new(min_choices: 1, max_choices: 1)
      @url = admin_conference_survey_survey_questions_path(@conference.short_title, @survey)
    end

    def create
      @survey_question = @survey.survey_questions.new(survey_question_params)
      if @survey_question.save
        redirect_to admin_conference_survey_path(@conference.short_title, @survey), notice: 'Successfully created Survey Question.'
      else
        @url = admin_conference_survey_survey_questions_path(@conference.short_title, @survey)
        render :new
      end
    end

    # GET questions/1/edit
    def edit
      @url = admin_conference_survey_survey_question_path(@conference.short_title, @survey, @survey_question)
    end

    # PUT questions/1
    def update
      if @survey_question.update(survey_question_params)
        redirect_to admin_conference_survey_path(@conference.short_title, @survey), notice: 'Successfully updated Survey Question.'
      else
        @url = admin_conference_survey_survey_question_path(@conference.short_title, @survey, @survey_question)
        render :edit
      end
    end

    # DELETE questions/1
    def destroy
      if @survey_question.destroy
        redirect_to admin_conference_survey_path(@conference.short_title, @survey), notice: 'Successfully deleted Survey Question.'
      else
        redirect_to admin_conference_survey_path(@conference.short_title, @survey), error: "Can't delete this Survey Question"
      end
    end

    private

    def survey_question_params
      params.require(:survey_question).permit(:title, :kind, :possible_answers, :min_choices, :max_choices, :mandatory)
    end
  end
end
