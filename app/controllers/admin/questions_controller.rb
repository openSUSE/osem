class Admin::QuestionsController < ApplicationController
  before_filter :verify_organizer

  def index
    @conference = Conference.find_by(short_title: params[:conference_id])
    @questions = Question.where(global: true).all | Question.where(conference_id: @conference.id)
    @questions_conference = @conference.questions
    @new_question = @conference.questions.new
  end

  def new
    @conference = Conference.find_by(short_title: params[:conference_id])
    @new_question = @conference.questions.new
  end

  def create
    @conference = Conference.find_by(short_title: params[:conference_id])
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
    @conference = Conference.find_by(short_title: params[:conference_id])
    @question = Question.find(params[:id])
    
    if @question.global == true && !has_role?(current_user, "Admin")
      redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), alert: "Sorry, you cannot edit global questions. Create a new one.")
    end
  end

  # PUT questions/1
  def update
       
    @conference = Conference.find_by(short_title: params[:conference_id])
    @question = Question.find(params[:id])

    if @question.update_attributes(params[:question])
      redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), notice: "Question '#{@question.title}' for #{@conference.short_title} successfully updated.")
    else
      redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), notice: "Update of questions for #{@conference.short_title} failed.")
    end
  end

  # Update questions used for the conference
  def update_conference
    @conference = Conference.find_by(short_title: params[:conference_id])

    if @conference.update_attributes(params[:conference])
      redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), notice: "Questions for #{@conference.short_title} successfully updated.")
    else
      redirect_to(admin_conference_questions_path(conference_id: @conference.short_title), notice: "Update of questions for #{@conference.short_title} failed.")
    end
  end

  # DELETE questions/1
  def destroy
    if has_role?(current_user, "Admin")
      @question = Question.find(params[:id])

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
