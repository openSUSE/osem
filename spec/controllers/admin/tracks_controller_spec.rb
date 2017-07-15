require 'spec_helper'

describe Admin::TracksController do
  let(:admin) { create(:admin) }

  let(:conference) { create(:conference) }
  let!(:track) { create(:track, program: conference.program, color: '#800080') }
  let!(:self_organized_track) { create(:track, :self_organized, program: conference.program) }

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
end
