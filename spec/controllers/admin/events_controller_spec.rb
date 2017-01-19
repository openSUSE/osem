require 'spec_helper'

describe Admin::EventsController do
  let!(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:event_type) { create :event_type }
  let(:event) { create(:event, program: conference.program) }

  context 'admin is signed in' do
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index, conference_id: conference.short_title }

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET #edit' do
      before { get :edit, conference_id: conference.short_title, id: event.id }

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns event variable' do
        expect(assigns(:event)).to be_instance_of(Event)
      end
    end

    describe 'GET #new' do
      before { get :new, conference_id: conference.short_title }

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'assigns event variable' do
        expect(assigns(:event)).to be_instance_of(Event)
      end
    end

    describe 'POST #create' do
      context 'saves successfuly' do
        before do
          post :create, event: attributes_for(:event, event_type_id: event_type.id).merge!(submitter_id: admin.id, speaker_id: admin.id), conference_id: conference.short_title
        end

        it 'redirects to admin events index path' do
          expect(response).to redirect_to admin_conference_program_events_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Event was successfully submitted.')
        end

        it 'creates new event' do
          expect(Event.find(event.id)).to be_instance_of(Event)
        end
      end

      context 'save fails' do
        before do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          post :create, event: attributes_for(:event), conference_id: conference.short_title
        end

        it 'renders new template' do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Could not create event: #{event.errors.full_messages.join(', ')}")
        end

        it 'does not create new event' do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          expect do
              post :create, event: attributes_for(:event, event_type_id: event_type.id),
                            conference_id: conference.short_title,
                            user: attributes_for(:user)
          end.not_to change{ Event.count }
        end
      end
    end
  end
end
