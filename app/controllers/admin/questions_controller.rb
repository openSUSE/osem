module Admin
  class QuestionsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource except: [:create]

    def index
      authorize! :index, Question.new(conference_id: @conference.id)
      @questions = Question.where(global: true).all | Question.where(conference_id: @conference.id) | @conference.questions
      @question = @conference.questions.new
    end

    def show
      @registrations = @conference.registrations.joins(:qanswers).where(qanswers: { question: @question })
    end

    def new
      @question = Question.new(conference_id: @conference.id)
      authorize! :create, @question
    end

    def create
      @question = @conference.questions.new(params[:question])
      @question.conference_id = @conference.id

      # We need to authorize the @question after a conference_id has been associated with the question,
      # because authorization in ability.rb is based on existence of conference_id attribute
      # (and the controller does not authorize through conference)
      authorize! :create, @question

      if @question.question_type == QuestionType.find_by(title: 'Yes/No')
        @question.answers = [ Answer.find_or_create_by(title: 'Yes'), Answer.find_or_create_by(title: 'No') ]
      end

      respond_to do |format|
        # Do not automatically associate newly created question with the conference. The new question shall be enabled for the conference manually.
        if @question.save
          format.html { redirect_to admin_conference_questions_path(@conference.short_title), notice: 'Question was successfully created.' }
        else
          flash[:error] = "Oops, couldn't save Question. #{@question.errors.full_messages.join('. ')}"
          format.html { redirect_to admin_conference_questions_path(@conference.short_title) }
        end
      end
    end

    # GET questions/1/edit
    def edit; end

    # PUT questions/1
    def update
      @question.assign_attributes(params[:question])

      if @question.question_type == QuestionType.find_by(title: 'Yes/No')
        @question.answers = [ Answer.find_or_create_by(title: 'Yes'), Answer.find_or_create_by(title: 'No') ]
      end

      if @question.save
        if @question.answers.blank?
          # A question without answers cannot be enabled for a conference
          @conference.questions.delete(@question)
        end

        flash[:notice] = "Question '#{@question.title}' for #{@conference.short_title} updated successfully."
        redirect_to admin_conference_questions_path(@conference.short_title)
      else
        flash[:error] = "Update of questions for #{@conference.short_title} failed. #{@question.errors.full_messages.join('. ')}"
        redirect_to admin_conference_questions_path(@conference.short_title)
      end
    end

    # Update questions used for the conference
    def toggle_question
      authorize! :update, Question.new(conference_id: @conference.id)

      ids = @conference.question_ids
      if params[:enable] == 'true'
        ids = ids.push(@question.id)
      elsif params[:enable] == 'false'
        ids.delete(@question.id)
      end

      if @conference.update(question_ids: ids)
        flash[:notice] = "Question '#{@question.title}' #{params[:enable]=='true' ? 'enabled' : 'disabled'} for #{@conference.title}."
      else
        flash[:error] = "Failed to #{params[:enable]=='true' ? 'enable' : 'disable'} question '#{@question.title}' for #{@conference.title}. Note: Only questions with answers can be enabled for a conference."
      end

      respond_to do |format|
        format.html do
          redirect_to admin_conference_questions_path(@conference.short_title)
        end
        format.js do
          render js: 'index'
        end
      end
    end

    # DELETE questions/1
    def destroy
      if can? :destroy, @question
        # Do not delete global questions
        if !@question.global || @question.conferences.blank?

          # Delete question and its answers
          begin
            Question.transaction do

              @question.answers.each do |a|
                a.destroy unless a.questions.any?
              end

              @question.destroy
              flash[:notice] = "Deleted question: #{@question.title}"
            end
          rescue ActiveRecord::RecordInvalid
            flash[:error] = 'Could not delete question.'
          end
        else
          flash[:error] = 'You cannot delete global questions that are currently being used for a conference.'
        end
      else
        flash[:error] = 'You cannot delete the question. Do you have the necessary permissions?'
      end

      @questions = Question.where(global: true).all | Question.where(conference_id: @conference.id) | @conference.questions
      redirect_to admin_conference_questions_path(@conference.short_title)
    end
  end
end
