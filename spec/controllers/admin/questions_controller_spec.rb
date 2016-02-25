require 'spec_helper'

describe Admin::QuestionsController, type: :controller do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }
  let(:question) { create(:question, conferences: [conference]) }

  context 'user is signed in' do
    before { sign_in(user) }

    describe 'GET #index' do
      before do
        get :index, conference_id: conference.short_title
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end

      it 'populates an array of questions and creates new question object' do
        global_questions = Question.where(global: true).all
        expect(assigns(:questions)).to match_array(global_questions)
        expect(assigns(:new_question)).to be_instance_of(Question)
      end
    end

    describe 'GET #show' do
      before do
        @registration = create(:registration, conference: conference)
        create(:qanswer, registrations: [@registration])
        get :show, conference_id: conference.short_title, id: question.id
      end

      it 'renders the show template' do
        expect(response).to render_template('show')
      end

      it 'assigns registration answers to registrations' do
        expect(assigns(:registrations)).to match_array([@registration])
      end
    end

    describe 'POST #create' do
      context 'saves successfully' do
        before do
          post :create, question: attributes_for(:question), conference_id: conference.short_title
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Question was successfully created.')
        end

        it 'redirects to questions index path' do
          expect(response).to redirect_to admin_conference_questions_path
        end
      end

      context 'save fails' do
        before do
          allow_any_instance_of(Question).to receive(:save).and_return(false)
          post :create, question: attributes_for(:question), conference_id: conference.short_title
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to include "Oops, couldn't save Question."
        end
      end
    end

    describe 'GET #edit' do
      context 'non global question' do
        before do
          get :edit, conference_id: conference.short_title, id: question.id
        end

        it 'renders the index template' do
          expect(response).to render_template('edit')
        end
      end

      context 'global question' do
        before do
          question.update_attributes(global: true)
          get :edit, conference_id: conference.short_title, id: question.id
        end

        it 'redirects to questions index path' do
          expect(response).to redirect_to admin_conference_questions_path(conference_id: conference.short_title)
        end

        it 'shows error in flash message' do
          expect(flash[:alert]).to include 'Sorry, you cannot edit global questions. Create a new one.'
        end
      end
    end

    describe 'PATCH #update' do
      context 'updates successfully' do
        before do
          patch :update, question: attributes_for(:question, global: true),
                         commit: 'Save',
                         conference_id: conference.short_title,
                         id: question.id
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match "Question '#{question.title}' for #{conference.short_title} successfully updated."
        end

        it 'redirects to questions index path' do
          expect(response).to redirect_to admin_conference_questions_path(conference_id: conference.short_title)
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Question).to receive(:save).and_return(false)
          patch :update, question: attributes_for(:question, global: true),
                         commit: 'Save',
                         conference_id: conference.short_title,
                         id: question.id
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to include "Update of questions for #{conference.short_title} failed."
        end
      end
    end

    describe 'PATCH #update_conference' do
      context 'updates successfully' do
        before do
          patch :update_conference, conference: { question_ids: ['', '1', '', '', '', '']},
                                    commit: 'Save Questions',
                                    conference_id: conference.short_title
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match "Questions for #{conference.short_title} successfully updated."
        end

        it 'redirects to questions index path' do
          expect(response).to redirect_to admin_conference_questions_path(conference_id: conference.short_title)
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Conference).to receive(:save).and_return(false)
          patch :update_conference, conference: { question_ids: ['', '1', '', '', '', '']},
                                    commit: 'Save Questions',
                                    conference_id: conference.short_title
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to include "Update of questions for #{conference.short_title} failed."
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'non gloabl question' do
        context 'deletes successfully' do
          before do
            xhr :delete, :destroy, conference_id: conference.short_title, id: question.id
          end

          it 'shows success message in flash notice' do
            expect(flash[:notice]).to include "Deleted question: #{question.title} and its answers:"
          end
        end

        context 'delete fails' do
          before do
            allow_any_instance_of(Question).to receive(:destroy).and_raise(ActiveRecord::RecordInvalid.new(question))
            xhr :delete, :destroy, conference_id: conference.short_title, id: question.id
          end

          it 'shows error in flash message' do
            expect(flash[:error]).to match 'Could not delete question.'
          end
        end
      end

      context 'global question' do
        before do
          question.update_attributes(global: true)
          xhr :delete, :destroy, conference_id: conference.short_title, id: question.id
        end

        it 'shows error in flash message' do
          expect(flash[:alert]).to match 'You cannot delete global questions.'
        end
      end
    end
  end
end
