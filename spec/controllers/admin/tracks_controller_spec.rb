require 'spec_helper'

describe Admin::TracksController do
  let(:admin) { create(:admin) }

  let(:conference) { create(:conference) }
  let!(:track) { create(:track, program: conference.program, color: '#800080') }
  let!(:self_organized_track) { create(:track, :self_organized, program: conference.program, name: 'My awesome track') }

  before :each do
    sign_in(admin)
  end

  describe 'GET #index' do
    before :each do
      get :index, conference_id: conference.short_title
    end

    it 'assigns @tracks with the correct values' do
      expect(assigns(:tracks).length).to eq 2
      expect(assigns(:tracks).include?(track)).to eq true
      expect(assigns(:tracks).include?(self_organized_track)).to eq true
    end

    it 'renders the index template' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before :each do
      get :show, conference_id: conference.short_title, id: track.short_name
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq track
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before :each do
      get :new, conference_id: conference.short_title
    end

    it 'assigns a new track with the correct conference' do
      expect(assigns(:track)).to be_a Track
      expect(assigns(:track).new_record?).to eq true
      expect(assigns(:track).program_id).to eq conference.program.id
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'saves successfuly' do
      before :each do
        post :create, track: attributes_for(:track), conference_id: conference.short_title
      end

      it 'assigns a new track with the correct conference' do
        expect(assigns(:track)).to be_a Track
        expect(assigns(:track).new_record?).to eq false
        expect(assigns(:track).program_id).to eq conference.program.id
      end

      it 'redirects to admin tracks index path' do
        expect(response).to redirect_to admin_conference_program_tracks_path(conference_id: conference.short_title)
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('Track successfully created.')
      end

      it 'creates new track' do
        expect(Track.find(assigns(:track).id)).to be_a Track
      end

      it 'the new tracks has the correct attributes' do
        expect(assigns(:track).state).to eq 'confirmed'
        expect(assigns(:track).cfp_active).to eq true
      end
    end

    context 'save fails' do
      before :each do
        allow_any_instance_of(Track).to receive(:save).and_return(false)
        post :create, track: attributes_for(:track, short_name: 'my_track'), conference_id: conference.short_title
      end

      it 'assigns a new track with the correct conference' do
        expect(assigns(:track)).to be_a Track
        expect(assigns(:track).new_record?).to eq true
        expect(assigns(:track).program_id).to eq conference.program.id
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end

      it 'shows error in flash message' do
        expect(flash[:error]).to match("Creating Track failed: #{assigns(:track).errors.full_messages.join('. ')}.")
      end

      it 'does not create a new track' do
        expect(conference.program.tracks.find_by(short_name: 'my_track')).to eq nil
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      get :edit, conference_id: conference.short_title, id: track.short_name
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq track
    end

    it 'renders the show template' do
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    context 'updates successfully' do
      before :each do
        patch :update, track: attributes_for(:track, color: '#FF0000'),
                       conference_id: conference.short_title,
                       id: track.short_name
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq track
      end

      it 'redirects to admin tracks index path' do
        expect(response).to redirect_to admin_conference_program_tracks_path(conference_id: conference.short_title)
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('Track successfully updated.')
      end

      it 'updates the track' do
        track.reload
        expect(track.color).to eq '#FF0000'
      end
    end

    context 'update fails' do
      before :each do
        allow_any_instance_of(Track).to receive(:save).and_return(false)
        patch :update, track: attributes_for(:track, color: '#FF0000'),
                       conference_id: conference.short_title,
                       id: track.short_name
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq track
      end

      it 'renders edit template' do
        expect(response).to render_template :edit
      end

      it 'shows error in flash message' do
        expect(flash[:error]).to match("Track update failed: #{assigns(:track).errors.full_messages.join('. ')}.")
      end

      it 'does not update the track' do
        track.reload
        expect(track.color).to eq '#800080'
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'deletes successfully' do
      before :each do
        delete :destroy, conference_id: conference.short_title, id: track.short_name
      end

      it 'redirects to admin tracks index path' do
        expect(response).to redirect_to admin_conference_program_tracks_path(conference_id: conference.short_title)
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('Track successfully deleted.')
      end

      it 'deletes the track' do
        expect(Track.find_by(id: track)).to eq nil
      end
    end

    context 'delete fails' do
      before :each do
        allow_any_instance_of(Track).to receive(:destroy).and_return(false)
        delete :destroy, conference_id: conference.short_title, id: track.short_name
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq track
      end

      it 'redirects to admin tracks index path' do
        expect(response).to redirect_to admin_conference_program_tracks_path(conference_id: conference.short_title)
      end

      it 'shows error in flash message' do
        expect(flash[:error]).to match("Track couldn't be deleted. #{track.errors.full_messages.join('. ')}.")
      end

      it 'does not delete the track' do
        expect(Track.find(track.id)).to eq track
      end
    end
  end

  describe 'PATCH #toggle_cfp_inclusion' do
    context 'cfp_active is false' do
      before :each do
        self_organized_track.cfp_active = false
        self_organized_track.save!
        patch :toggle_cfp_inclusion, conference_id: conference.short_title, id: self_organized_track.short_name
        self_organized_track.reload
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq self_organized_track
      end

      it 'becomes true' do
        expect(self_organized_track.cfp_active).to eq true
      end
    end

    context 'cfp_active is true' do
      before :each do
        self_organized_track.cfp_active = true
        self_organized_track.save!
        patch :toggle_cfp_inclusion, conference_id: conference.short_title, id: self_organized_track.short_name
        self_organized_track.reload
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq self_organized_track
      end

      it 'becomes false' do
        expect(self_organized_track.cfp_active).to eq false
      end
    end
  end

  describe 'PATCH #restart' do
    before :each do
      self_organized_track.state = 'canceled'
      self_organized_track.save!
      patch :restart, conference_id: conference.short_title, id: self_organized_track.short_name
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Review for My awesome track started!'
    end

    it 'changes the track\'s state to new' do
      expect(self_organized_track.state).to eq 'new'
    end
  end

  describe 'PATCH #to_accept' do
    before :each do
      patch :to_accept, conference_id: conference.short_title, id: self_organized_track.short_name
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track marked as a possible acceptance!'
    end

    it 'changes the track\'s state to to_accept' do
      expect(self_organized_track.state).to eq 'to_accept'
    end
  end

  describe 'PATCH #accept' do
    shared_examples 'fails to accept' do |start_date, end_date, room|
      before :each do
        self_organized_track.start_date = start_date ? Date.today : nil
        self_organized_track.end_date = end_date ? Date.today : nil
        if room
          conference.venue = create(:venue)
          self_organized_track.room = create(:room, venue: conference.venue)
        else
          self_organized_track.room = nil
        end
        self_organized_track.save!

        patch :accept, conference_id: conference.short_title, id: self_organized_track.short_name
        self_organized_track.reload
      end

      it 'redirects to Tracks#edit' do
        expect(response).to redirect_to edit_admin_conference_program_track_path(conference.short_title, self_organized_track)
      end

      it 'shows message in flash alert' do
        expect(flash[:alert]).to eq 'Please make sure that the track has a room and start/end dates before accepting it'
      end
    end

    context 'has start_date, end_date and room' do
      before :each do
        self_organized_track.start_date = Date.today
        self_organized_track.end_date = Date.today
        conference.venue = create(:venue)
        self_organized_track.room = create(:room, venue: conference.venue)
        self_organized_track.save!

        patch :accept, conference_id: conference.short_title, id: self_organized_track.short_name
        self_organized_track.reload
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq self_organized_track
      end

      it 'shows message in flash notice' do
        expect(flash[:notice]).to eq 'Track My awesome track accepted!'
      end

      it 'changes the track\'s state to accepted' do
        expect(self_organized_track.state).to eq 'accepted'
      end
    end

    context 'has start_date and end_date' do
      it_behaves_like 'fails to accept', true, true, false
    end

    context 'has start_date and room' do
      it_behaves_like 'fails to accept', true, false, true
    end

    context 'has start_date' do
      it_behaves_like 'fails to accept', true, false, false
    end

    context 'has end_date and room' do
      it_behaves_like 'fails to accept', false, true, true
    end

    context 'has end_date' do
      it_behaves_like 'fails to accept', false, true, false
    end

    context 'has room' do
      it_behaves_like 'fails to accept', false, false, true
    end

    context 'has non of start_date, end_date, room' do
      it_behaves_like 'fails to accept', false, false, false
    end
  end

  describe 'PATCH #confirm' do
    before :each do
      self_organized_track.state = 'accepted'
      self_organized_track.save!
      patch :confirm, conference_id: conference.short_title, id: self_organized_track.short_name
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track confirmed!'
    end

    it 'changes the track\'s state to confirmed' do
      expect(self_organized_track.state).to eq 'confirmed'
    end
  end

  describe 'PATCH #to_reject' do
    before :each do
      patch :to_reject, conference_id: conference.short_title, id: self_organized_track.short_name
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track marked as a possible rejection!'
    end

    it 'changes the track\'s state to to_reject' do
      expect(self_organized_track.state).to eq 'to_reject'
    end
  end

  describe 'PATCH #reject' do
    before :each do
      patch :reject, conference_id: conference.short_title, id: self_organized_track.short_name
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track rejected!'
    end

    it 'changes the track\'s state to rejected' do
      expect(self_organized_track.state).to eq 'rejected'
    end
  end

  describe 'PATCH #cancel' do
    before :each do
      self_organized_track.state = 'confirmed'
      self_organized_track.save!
      patch :cancel, conference_id: conference.short_title, id: self_organized_track.short_name
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track canceled!'
    end

    it 'changes the track\'s state to canceled' do
      expect(self_organized_track.state).to eq 'canceled'
    end
  end
end
