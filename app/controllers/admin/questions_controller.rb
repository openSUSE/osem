module Admin
  class QuestionsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :question, through: :conference

    def index
      @questions = Question.where(global: true).all | Question.where(conference_id: @conference.id)
      @questions_conference = @conference.questions
      @new_question = @conference.questions.new
    end

    def new
      @new_question = @conference.questions.new
    end

    def create
      @question = @conference.questions.new(params[:question])
      @question.conference_id = @conference.id

      respond_to do |format|
        if @conference.save
          format.html { redirect_to admin_conference_questions_path, notice: 'Question was successfully created.' }
        else
          flash[:error] = "Oops, couldn't save. Question and answer(s) have titles?"
          format.html { redirect_to admin_conference_questions_path }
        end
      end
    end

    # GET questions/1/edit
    def edit

      @question = Question.find(params[:id])

      if @question.global == true && !(current_user.has_role? :organizer, @conference)
        redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), alert: "Sorry, you cannot edit global questions. Create a new one.")
      end
    end

    # PUT questions/1
    def update
      @question = Question.find(params[:id])

      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), notice: "Questions for #{@conference.short_title} successfully updated.")
      else
        redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), notice: "Update of questions for #{@conference.short_title} failed.")
      end
    end

    # Update questions used for the conference
    def update_conference
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_questions_path(:conference_id => @conference.short_title), :notice => "Questions for #{@conference.short_title} successfully updated.")
      else
        redirect_to(admin_conference_questions_path(:conference_id => @conference.short_title), :notice => "Update of questions for #{@conference.short_title} failed.")
      end
    end

    # DELETE questions/1
    def destroy
      if can? :destroy, @question

        # Do not delete global questions
        if @question.global == false

          # Delete question and its answers
          begin
            Question.transaction do

              @question.delete
              @question.answers.each do |a|
                a.delete
              end
              flash[:notice] = "Deleted question: #{@question.title} and its answers: #{@question.answers.map {|a| a.title}.join ','}"
          end
          rescue ActiveRecord::RecordInvalid
            flash[:error] = "Could not delete question."
          end
        else
          flash[:error] = "You cannot delete global questions."
        end
      else
        flash[:error] = "You must be an admin to delete a question."
      end

    @questions = Question.where(global: true).all | Question.where(conference_id: @conference.id)
    @questions_conference = @conference.questions
  end
end
