require 'spec_helper'

describe Admin::QuestionsController do
  let!(:conference) { create(:conference, title: 'my conference') }
  let!(:question_with_answers) { create(:question_with_answers, conference_id: conference.id) }
  let!(:question_without_answers) { create(:question, conference_id: conference.id) }
  let(:question_type_yes_no) { QuestionType.find_by(title: 'Yes/No') }
  let(:question_type_single_choice) { create(:single_choice) }
  let(:first_answer) { create(:first_answer) }
  let(:second_answer) { create(:second_answer) }
  let(:organizer) { create(:organizer) }
  let(:question)  { create(:question, title: 'test title', question_type_id: create(:single_choice).id) }

  before(:each) do
    sign_in(organizer)
  end

  describe 'PATCH #toggle_question' do
    it 'enables a question for a conference if the question has answers' do
      patch :toggle_question, conference_id: conference.short_title, id: question_with_answers, enable: 'true'

      conference.reload

      expect(conference.question_ids).to eq([question_with_answers.id])
      expect(conference.question_ids).to_not include([question_without_answers.id])

      expect(flash[:notice]).to eq("Question 'Which do you choose?' enabled for my conference.")
      expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
    end

    it 'disables a question for a conference if the question has answers' do
      patch :toggle_question, conference_id: conference.short_title, id: question_with_answers, enable: 'true'
      patch :toggle_question, conference_id: conference.short_title, id: question_with_answers, enable: 'false'

      conference.reload

      expect(conference.question_ids).to eq([])
      expect(conference.question_ids).to_not include([question_with_answers.id])

      expect(flash[:notice]).to eq("Question 'Which do you choose?' disabled for my conference.")
      expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
    end
  end

  describe 'GET #index' do
    it 'renders the index template' do

      get :index, conference_id: conference.short_title
      expect(response).to render_template :index
    end

    it 'properly assigns questions, when conference does not have enabled questions' do
      questions_global = Question.where(global: true)

      get :index, conference_id: conference.short_title

      questions_array = questions_global.to_a
      questions_array << question_with_answers
      questions_array << question_without_answers
      expect(assigns(:questions)).to match_array(questions_array)
    end
  end

  describe 'GET #show' do
    before :each do
      @registration = create(:registration, conference: conference)
      conference.questions << question_with_answers
      @registration.qanswers << question_with_answers.qanswers.first
    end
    it 'properly assigns registrations' do
      get :show, conference_id: conference.short_title, id: question_with_answers.id
      expect(assigns(:registrations).to_a).to eq [@registration]
    end
  end

  describe 'POST #create' do
    context 'creates a question' do
      before :each do
        @expected = Question.count + 1
        post :create, conference_id: conference.short_title, question: attributes_for(:question, title: 'test',
                                                                                                 question_type_id: question_type_single_choice.id)
      end

      it 'successfully' do
        expect(Question.count).to eq @expected
      end

      it 'assigns question object with correct attributes' do
        expect(assigns(:question).title).to eq 'test'
        expect(assigns(:question).conference_id).to eq conference.id
      end

      it 'renders flash with success message' do
        expect(flash[:notice]).to eq 'Question was successfully created.'
      end

      it 'redirects to index' do
        expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
      end
    end

    context 'creates a question with Yes/No question type' do
      before :each do
        @expected = Question.count + 1
        post :create, conference_id: conference.short_title, question: attributes_for(:question, title: 'test',
                                                                                                 question_type_id: QuestionType.find_by(title: 'Yes/No').id)
      end

      it 'successfully' do
        expect(Question.count).to eq @expected
      end

      it 'assigns question object with correct attributes' do
        expect(assigns(:question).title).to eq 'test'
        expect(assigns(:question).conference_id).to eq conference.id
      end

      it 'renders flash with success message' do
        expect(flash[:notice]).to eq 'Question was successfully created.'
      end

      it 'redirects to index' do
        expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
      end

      it 'assigns answers automatically' do
        expect(assigns(:question).answers.to_a).to eq [ Answer.find_by(title: 'Yes'), Answer.find_by(title: 'No') ]
      end
    end

    context 'with invalid attributes' do
      before :each do
        @expected = Question.count
        post :create, conference_id: conference.short_title, question: attributes_for(:question, title: '', question_type_id: question_type_single_choice.id)
      end

      it 'does not save the new question in database' do
        expect(Question.count).to eq @expected
      end

      it 'redirects to index page' do
        expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
      end

      it 'shows flash error message' do
        expect(flash[:error]).to eq "Oops, couldn't save Question. Title can't be blank"
      end
    end
  end

  describe 'PATCH #update' do
    before :each do
      question.answers << first_answer
      question.answers << second_answer
      question.conferences << conference
    end

    context 'with invalid attributes' do
      before :each do
        patch :update, conference_id: conference.short_title, id: question.id, question: attributes_for(:question, title: '')
      end

      it 'does not save the question' do
        expect(question.title).to eq 'test title'
      end

      it 'renders failure flash error message' do
        expect(flash[:error]).to eq "Update of questions for #{conference.short_title} failed. Title can't be blank"
      end

      it 'redirects to index' do
        expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
      end
    end

    context 'with valid attibutes' do
      before :each do
        patch :update, conference_id: conference.short_title, id: question.id, question: attributes_for(:question, title: 'new title')
      end

      it 'successfully' do
        question.reload
        expect(question.title).to eq 'new title'
      end

      it 'renders success flash notice message' do
        question.reload
        expect(flash[:notice]).to eq "Question 'new title' for #{conference.short_title} updated successfully."
      end

      it 'redirects to index' do
        expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
      end
    end

    it 'disables question for conference, if question does not have answers' do
      question.answers = []
      patch :update, conference_id: conference.short_title, id: question.id, question: attributes_for(:question)

      question.reload
      expect(question.conferences).to eq []
    end
  end

  describe 'DELETE #destroy' do
    context 'global questions' do
      it 'deletes question not used in any conference' do
        global_question = Question.find_by(global: true)

        expected = Question.count - 1
        delete :destroy, conference_id: conference.short_title, id: global_question.id

        expect(Question.count).to eq expected
      end

      it 'does not delete question used in a conference' do
        global_question = Question.find_by(global: true)
        conference.questions << global_question

        expected = Question.count
        delete :destroy, conference_id: conference.short_title, id: global_question.id

        expect(Question.count).to eq expected
      end
    end

    context 'not global questions' do
      it 'deletes a question not used in the conference' do
        expected = Question.count - 1
        expect(conference.questions).not_to include question_with_answers

        delete :destroy, conference_id: conference.short_title, id: question_with_answers.id

        expect(Question.count).to eq expected
      end

      it 'deletes question used in a conference' do
        conference.questions << question_with_answers
        expect(question_with_answers.conferences).to include conference

        expected = Question.count - 1
        delete :destroy, conference_id: conference.short_title, id: question_with_answers.id

        expect(Question.count).to eq expected
      end
    end
  end
end
