require 'spec_helper'

describe ProposalController do
  let!(:first_user) { create(:user) }
  let(:conference) { create(:conference, short_title: 'lama101') }
  let(:event) { create(:event, program: conference.program) }

  context 'user is not signed in' do
    describe 'POST #create' do
      it 'is a pending example'
    end
  end

  context 'even submitter is signed in' do
    before do
      sign_in event.submitter
    end

    describe 'GET #index' do
      before { get :index, conference_id: conference.short_title }

      it 'assigns conference, program and events variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:program)).to eq conference.program
        expect(assigns(:events)).to eq [event]
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET #show' do
      before do
        get :show, conference_id: conference.short_title, id: event.id
      end

      it 'assigns event and speaker variables' do
        expect(assigns(:event)).to eq event
        expect(assigns(:speaker)).to eq event.submitter
      end

      it 'renders show template' do
        expect(response).to render_template('show')
      end
    end

    describe 'GET #new' do
      before { get :new, conference_id: conference.short_title }

      it 'assigns user and url variables' do
        expect(assigns(:user)).to be_instance_of(User)
        expect(assigns(:url)).to eq '/conference/lama101/program/proposal'
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
    end

    describe 'GET #edit' do
      before do
        get :edit, conference_id: conference.short_title, id: event.id
      end

      it 'assigns event and url variables' do
        expect(assigns(:event)).to eq event
        expect(assigns(:url)).to eq '/conference/lama101/program/proposal/1'
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
    end

    describe 'POST #create' do

      it 'assigns url variables', run: true do
        post :create, event: attributes_for(:event, event_type_id: 1),
                      conference_id: conference.short_title
        expect(assigns(:url)).to eq '/conference/lama101/program/proposal'
      end

      context 'creates proposal successfully' do
        before(:each, run: true) do
          post :create, event: attributes_for(:event, event_type_id: 1),
                        conference_id: conference.short_title
        end

        it 'assigns event variable', run: true do
          expect(assigns(:event)).not_to be_nil
        end

        it 'assigns program to event', run: true do
          expect(assigns(:event).program).to eq conference.program
        end

        it 'assigns submitter and speaker to event', run: true do
          expect(assigns(:event).submitter).to eq event.submitter
          expect(assigns(:event).speakers.first).to eq event.submitter
        end

        it 'redirects to proposal index path', run: true do
          expect(response).to redirect_to conference_program_proposal_index_path conference.short_title
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match('Proposal was successfully submitted.')
        end

        it 'creates new event' do
          expect do
            post :create, event: attributes_for(:event, event_type_id: 1),
                          conference_id: conference.short_title
          end.to change{ Event.count }.by 1
        end
      end

      context 'proposal save fails' do
        before(:each, run: true) do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          post :create, event: attributes_for(:event, event_type_id: 1),
                        conference_id: conference.short_title
        end

        it 'renders new template', run: true do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message', run: true do
          expect(flash[:error]).to match("Could not submit proposal: #{event.errors.full_messages.join(', ')}")
        end

        it 'does not create new proposal' do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          expect do
            post :create, event: attributes_for(:event, event_type_id: 1),
                          conference_id: conference.short_title
          end.not_to change{ Event.count }
        end
      end
    end

    describe 'PATCH #update' do

      it 'assigns url variable' do
        patch :update, event: attributes_for(:event, title: 'some title', event_type_id: 1),
                       conference_id: conference.short_title,
                       id: event.id
        expect(assigns(:url)).to eq '/conference/lama101/program/proposal/1'
      end

      context 'updates successfully' do
        before do
          patch :update, event: attributes_for(:event, title: 'some title', event_type_id: 1),
                         conference_id: conference.short_title,
                         id: event.id
        end

        it 'updates the proposal' do
          event.reload
          expect(event.title).to eq 'some title'
        end

        it 'redirects to proposal index path' do
          expect(response).to redirect_to conference_program_proposal_index_path conference.short_title
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Proposal was successfully updated.')
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          patch :update, event: attributes_for(:event, title: 'some title', event_type_id: 1),
                         conference_id: conference.short_title,
                         id: event.id
        end

        it 'does not update the proposal' do
          event.reload
          expect(event.title).not_to eq 'some title'
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message', run: true do
          expect(flash[:error]).to match("Could not update proposal: #{event.errors.full_messages.join(', ')}")
        end
      end
    end

    describe 'DELETE #destroy' do

      it 'assigns url variable' do
        delete :destroy, conference_id: conference.short_title, id: event.id
        expect(assigns(:url)).to eq '/conference/lama101/program/proposal/1'
      end

      context 'withdraws successfully' do
        before do
          delete :destroy, conference_id: conference.short_title, id: event.id
        end

        it 'changes state of event to withdrawn' do
          event.reload
          expect(event.withdrawn?).to be true
        end

        it 'redirects to proposal index path' do
          expect(response).to redirect_to conference_program_proposal_index_path conference.short_title
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Proposal was successfully withdrawn.')
        end
      end

      context 'withdraw fails' do
        before do
          request.env['HTTP_REFERER'] = '/'
          allow_any_instance_of(Event).to receive(:withdraw).and_raise(Transitions::InvalidTransition)
          delete :destroy, conference_id: conference.short_title, id: event.id
        end

        it 'does not withdraw event' do
          event.reload
          expect(event.withdrawn?).to be false
        end

        it 'redirects to previous path' do
          expect(response).to redirect_to '/'
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Event can't be withdrawn")
        end
      end
    end

    describe 'PATCH #confirm' do
      context 'confirmed successfully' do
        before { event.update_attributes(state: 'unconfirmed') }

        it 'assigns url variable' do
          patch :confirm, conference_id: conference.short_title, id: event.id
          expect(assigns(:url)).to eq '/conference/lama101/program/proposal/1'
        end

        context 'user has registered for the conference' do
          before do
            create(:registration, conference: conference, user: event.submitter)
            patch :confirm, conference_id: conference.short_title, id: event.id
          end

          it 'change state of event to confirmed' do
            event.reload
            expect(event.confirmed?).to be true
          end

          it 'redirects to proposal index path' do
            expect(response).to redirect_to conference_program_proposal_index_path conference.short_title
          end

          it 'shows success message in flash notice' do
            expect(flash[:notice]).to match('The proposal was confirmed.')
          end
        end

        context 'user has not registered for the conference' do
          before do
            patch :confirm, conference_id: conference.short_title, id: event.id
          end

          it 'change state of event to confirmed' do
            event.reload
            expect(event.confirmed?).to be true
          end

          it 'redirects to new registration path' do
            expect(response).to redirect_to new_conference_conference_registrations_path conference.short_title
          end

          it 'shows flash alert asking user to register' do
            expect(flash[:alert]).to match('The proposal was confirmed. Please register to attend the conference.')
          end
        end
      end

      context 'confirm failed' do
        context 'event was not accepted' do
          before do
            request.env['HTTP_REFERER'] = '/'
            patch :confirm, conference_id: conference.short_title, id: event.id
          end

          it 'does not confirm event' do
            expect(event.confirmed?).to be false
          end

          it 'redirects to previous path' do
            expect(response).to redirect_to '/'
          end

          it 'shows error in flash message' do
            expect(flash[:error]).to match("Event can't be confirmed")
          end
        end

        context 'event was accepted' do
          context 'event save fails' do
            before do
              event.update_attributes(state: 'unconfirmed')
              allow_any_instance_of(Event).to receive(:save).and_return(false)
              patch :confirm, conference_id: conference.short_title, id: event.id
            end

            it 'does not confirm event' do
              expect(event.confirmed?).to be false
            end

            it 'renders new template' do
              expect(response).to render_template('new')
            end

            it 'shows error in flash message' do
              expect(flash[:error]).to match("Could not confirm proposal: #{event.errors.full_messages.join(', ')}")
            end
          end
        end
      end
    end

    describe 'PATCH #restart' do
      before { event.update_attributes(state: 'withdrawn') }

      it 'assigns url variable' do
        patch :restart, conference_id: conference.short_title, id: event.id
        expect(assigns(:url)).to eq '/conference/lama101/program/proposal/1'
      end

      context 'resubmits successfully' do
        before do
          patch :restart, conference_id: conference.short_title, id: event.id
        end

        it 'changes state of event to new' do
          event.reload
          expect(event.new?).to be true
        end

        it 'redirects to proposal index path' do
          expect(response).to redirect_to conference_program_proposal_index_path conference.short_title
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match("The proposal was re-submitted. The #{conference.short_title} organizers will review it again.")
        end
      end

      context 'resubmission fails' do
        before do
          allow_any_instance_of(Event).to receive(:restart).and_raise(Transitions::InvalidTransition)
          patch :restart, conference_id: conference.short_title, id: event.id
        end

        it 'does not change state of event to new' do
          event.reload
          expect(event.new?).to be false
        end

        it 'redirects to previous path' do
          expect(response).to redirect_to conference_program_proposal_index_path conference.short_title
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("The proposal can't be re-submitted.")
        end
      end

      context 'event save fails' do
        before do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          patch :restart, conference_id: conference.short_title, id: event.id
        end

        it 'does not change state of event to new' do
          event.reload
          expect(event.new?).to be false
        end

        it 'renders new template' do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Could not re-submit proposal: #{event.errors.full_messages.join(', ')}")
        end
      end
    end
  end
end
