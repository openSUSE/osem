module Admin
  class SurveyQuestionsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :survey, through: :conference
    load_and_authorize_resource through: :survey

    def index
    end

    def show
    end

    def new
      @survey_question = @survey.survey_questions.new
      @url = admin_conference_survey_survey_questions_path(@conference.short_title, @survey)
    end

    def create
      @survey.survey_questions.create(survey_question_params)
      redirect_to admin_conference_survey_survey_questions_path(@conference.short_title, @survey)
    end

    # GET questions/1/edit
    def edit
      @url = admin_conference_survey_survey_question_path(@conference.short_title, @survey, @survey_question)
    end

    # PUT questions/1
    def update
      if @survey_question.update_attributes(survey_question_params)
        redirect_to admin_conference_survey_survey_questions_path(@conference.short_title, @survey), notice: 'Successfully updated survey question.'
      else
        render :edit
      end
    end

    # DELETE questions/1
    def destroy
    end

    private

    def survey_question_params
      params.require(:survey_question).permit(:title, :kind, :possible_answers, :min_choices, :max_choices, :mandatory)
    end
  end
end
