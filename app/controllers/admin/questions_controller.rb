# frozen_string_literal: true

module Admin
  class QuestionsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource except: [:new, :create]

    def index
      authorize! :index, Question.new(conference_id: @conference.id)
      @questions = Question.where(global: true) | @conference.questions
      @questions_conference = @conference.questions
      @new_question = @conference.questions.new
    end

    def show
      @registrations = @conference.registrations.joins(:qanswers).uniq
    end

    def new
      @question = Question.new(conference_id: @conference.id)
      authorize! :create, @question
    end

    def create
      @question = @conference.questions.new(question_params)
      @question.conference_id = @conference.id
      authorize! :create, @question

      if @question.question_type_id == QuestionType.find_by(title: 'Yes/No').id
        @question.answers = [Answer.find_by(title: 'Yes'), Answer.find_by(title: 'No')]
      end

      respond_to do |format|
        if @conference.save
          format.html { redirect_to admin_conference_questions_path, notice: 'Question was successfully created.' }
        else
          format.html { redirect_to admin_conference_questions_path, error: "Oops, couldn't save Question. #{@question.errors.full_messages.join('. ')}" }
        end
      end
    end

    # GET questions/1/edit
    def edit
      if @question.global
        redirect_to admin_conference_questions_path(conference_id: @conference.short_title), error: 'Sorry, you cannot edit global questions. Create a new one.'
      end
    end

    # PUT questions/1
    def update
      if @question.update(question_params)
        redirect_to admin_conference_questions_path(conference_id: @conference.short_title), notice: "Question '#{@question.title}' for #{@conference.short_title} successfully updated."
      else
        redirect_to admin_conference_questions_path(conference_id: @conference.short_title), notice: "Update of questions for #{@conference.short_title} failed. #{@question.errors.full_messages.join('. ')}"
      end
    end

    # Update questions used for the conference
    def update_conference
      authorize! :update, Question.new(conference_id: @conference.id)
      if @conference.update(conference_params)
        redirect_to admin_conference_questions_path(conference_id: @conference.short_title), notice: "Questions for #{@conference.short_title} successfully updated."
      else
        redirect_to admin_conference_questions_path(conference_id: @conference.short_title), notice: "Update of questions for #{@conference.short_title} failed."
      end
    end

    # DELETE questions/1
    def destroy
      if can? :destroy, @question
        # Do not delete global questions
        if @question.global
          flash[:error] = 'You cannot delete global questions.'
        else
          # Delete question and its answers
          begin
            Question.transaction do

              @question.destroy
              @question.answers.each do |a|
                a.destroy
              end
              flash[:notice] = "Deleted question: #{@question.title} and its answers: #{@question.answers.map {|a| a.title}.join ','}"
            end
          rescue ActiveRecord::RecordInvalid
            flash[:error] = 'Could not delete question.'
          end
        end
      else
        flash[:error] = 'You must be an admin to delete a question.'
      end

      @questions = Question.where(global: true).all | Question.where(conference_id: @conference.id)
      @questions_conference = @conference.questions
    end

    private

    def question_params
      params.require(:question).permit(:title, :global, :answer_ids, :question_type_id, :conference_id, answers_attributes: [:id, :title])
    end

    def conference_params
      params.require(:conference).permit(question_ids: [])
    end
  end
end
