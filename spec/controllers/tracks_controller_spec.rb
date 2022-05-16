# frozen_string_literal: true

require 'spec_helper'

describe TracksController do
  let(:user) { create(:admin) }

  let(:conference) { create(:conference) }
  let!(:regular_track) { create(:track, program: conference.program) }
  let!(:self_organized_track) { create(:track, :self_organized, program: conference.program, submitter: user, name: 'My awesome track', color: '#800080') }

  before :each do
    sign_in(user)
  end

  describe 'GET #index' do
    before :each do
      get :index, params: { conference_id: conference.short_title }
    end

    it 'assigns @tracks with the correct values' do
      expect(assigns(:tracks).length).to eq 1
      expect(assigns(:tracks).include?(regular_track)).to be false
      expect(assigns(:tracks).include?(self_organized_track)).to be true
    end

    it 'renders the index template' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before :each do
      get :show, params: { conference_id: conference.short_title, id: self_organized_track.short_name }
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before :each do
      get :new, params: { conference_id: conference.short_title }
    end

    it 'assigns a new track with the correct conference' do
      expect(assigns(:track)).to be_a Track
      expect(assigns(:track).new_record?).to be true
      expect(assigns(:track).program_id).to eq conference.program.id
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'saves successfuly' do
      before :each do
        post :create, params: { track: attributes_for(:track, :self_organized, short_name: 'my_track'), conference_id: conference.short_title }
      end

      it 'redirects to tracks index path' do
        expect(response).to redirect_to conference_program_tracks_path(conference_id: conference.short_title)
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('Track request successfully created.')
      end

      it 'creates new track' do
        expect(assigns(:track).new_record?).to be false
      end

      it 'the new tracks has the correct attributes' do
        expect(assigns(:track).program_id).to eq conference.program.id
        expect(assigns(:track).submitter).to eq user
        expect(assigns(:track).state).to eq 'new'
        expect(assigns(:track).cfp_active).to be false
      end
    end

    context 'save fails' do
      before :each do
        allow_any_instance_of(Track).to receive(:save).and_return(false)
        post :create, params: { track: attributes_for(:track, :self_organized, short_name: 'my_track'), conference_id: conference.short_title }
      end

      it 'assigns a new track with the correct conference' do
        expect(assigns(:track)).to be_a Track
        expect(assigns(:track).new_record?).to be true
        expect(assigns(:track).program_id).to eq conference.program.id
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end

      it 'shows error in flash message' do
        expect(flash[:error]).to match("Creating Track request failed: #{assigns(:track).errors.full_messages.join('. ')}.")
      end

      it 'does not create a new track' do
        expect(conference.program.tracks.find_by(short_name: 'my_track')).to be_nil
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      get :edit, params: { conference_id: conference.short_title, id: self_organized_track.short_name }
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'renders the show template' do
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    context 'updates successfully' do
      before :each do
        patch :update, params: { track:         attributes_for(:track, :self_organized, color: '#FF0000'),
                                 conference_id: conference.short_title,
                                 id:            self_organized_track.short_name }
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq self_organized_track
      end

      it 'redirects to tracks index path' do
        expect(response).to redirect_to conference_program_tracks_path(conference_id: conference.short_title)
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('Track request successfully updated.')
      end

      it 'updates the track' do
        self_organized_track.reload
        expect(self_organized_track.color).to eq '#FF0000'
      end
    end

    context 'update fails' do
      before :each do
        allow_any_instance_of(Track).to receive(:save).and_return(false)
        patch :update, params: { track:         attributes_for(:track, :self_organized, color: '#FF0000'),
                                 conference_id: conference.short_title,
                                 id:            self_organized_track.short_name }
      end

      it 'assigns the correct track' do
        expect(assigns(:track)).to eq self_organized_track
      end

      it 'renders edit template' do
        expect(response).to render_template :edit
      end

      it 'shows error in flash message' do
        expect(flash[:error]).to match("Track request update failed: #{assigns(:track).errors.full_messages.join('. ')}.")
      end

      it 'does not update the track' do
        self_organized_track.reload
        expect(self_organized_track.color).to eq '#800080'
      end
    end
  end

  describe 'PATCH #restart' do
    before :each do
      self_organized_track.state = 'withdrawn'
      self_organized_track.save!
      patch :restart, params: { conference_id: conference.short_title, id: self_organized_track.short_name }
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track re-submitted.'
    end

    it 'changes the track\'s state to new' do
      expect(self_organized_track.state).to eq 'new'
    end
  end

  describe 'PATCH #confirm' do
    before :each do
      self_organized_track.state = 'accepted'
      self_organized_track.save!
      patch :confirm, params: { conference_id: conference.short_title, id: self_organized_track.short_name }
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track confirmed.'
    end

    it 'changes the track\'s state to confirmed' do
      expect(self_organized_track.state).to eq 'confirmed'
    end
  end

  describe 'PATCH #withdraw' do
    before :each do
      self_organized_track.state = 'confirmed'
      self_organized_track.save!
      patch :withdraw, params: { conference_id: conference.short_title, id: self_organized_track.short_name }
      self_organized_track.reload
    end

    it 'assigns the correct track' do
      expect(assigns(:track)).to eq self_organized_track
    end

    it 'shows message in flash notice' do
      expect(flash[:notice]).to eq 'Track My awesome track withdrawn.'
    end

    it 'changes the track\'s state to withdrawn' do
      expect(self_organized_track.state).to eq 'withdrawn'
    end
  end
end
