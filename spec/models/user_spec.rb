# frozen_string_literal: true

require 'spec_helper'

describe User do

  let(:user_admin) { create(:admin) }
  let(:conference) { create(:conference, short_title: 'oSC16', title: 'openSUSE Conference 2016') }
  let(:conference2) { create(:conference, short_title: 'oSC15', title: 'openSUSE Conference 2015') }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:cfp_role) { Role.find_by(name: 'cfp', resource: conference) }
  let(:volunteers_coordinator_role) { Role.find_by(name: 'volunteers_coordinator', resource: conference) }
  let(:organizer) { create(:organizer, resource: conference) }
  let(:user) { create(:user) }
  let(:user_disabled) { create(:user, :disabled) }

  let(:event1) { create(:event, program: conference.program) }
  let(:another_conference) { create(:conference) }
  let(:event2) { create(:event, program: another_conference.program) }
  let(:registration) { create(:registration, user: user, conference: conference) }
  let(:events_registration) { create(:events_registration, event: event1, registration: registration) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).ignoring_case_sensitivity }

    it 'biography can not have more than 150 words' do
      # Text with 151 words
      long_text = <<-EOS
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
        vestibulum, augue ut accumsan feugiat, mauris eros accumsan nunc,
        volutpat vulputate eros orci quis nulla. Cum sociis natoque penatibus
        et magnis dis parturient montes, nascetur ridiculus mus. Sed varius
        orci ut lectus convallis, et ultrices ex finibus. Praesent orci augue,
        aliquet at cursus at, placerat id ligula. Vestibulum a mauris non
        felis pretium laoreet. Cras vel nisl convallis, pharetra ipsum at,
        mattis erat. Praesent in lectus felis. Fusce eros mauris, euismod
        lobortis metus id, tristique scelerisque nisl. Suspendisse potenti.
        Suspendisse ac metus magna. Integer lobortis pharetra eros euismod
        fringilla. Phasellus vitae orci vel magna laoreet mattis non eu neque.
        Mauris ac dictum leo. Nullam dapibus convallis molestie. Integer
        dignissim massa at odio feugiat tempus. Pellentesque ultrices rutrum
        eros, a pellentesque lorem auctor in. Suspendisse sollicitudin dolor
        vitae justo dignissim, a condimentum turpis molestie. Aenean
        scelerisque, arcu eu congue mollis, nibh nulla finibus.
      EOS
      expect(build(:user, biography: long_text)).to_not be_valid
    end
  end

  describe 'association' do
    it { is_expected.to have_many(:openids) }
    it { is_expected.to have_many(:event_users).dependent(:destroy) }
    it { is_expected.to have_many(:events).through(:event_users) }
    it { is_expected.to have_many(:registrations).dependent(:destroy) }
    it { is_expected.to have_many(:events_registrations).through(:registrations) }
    it { is_expected.to have_many(:ticket_purchases).dependent(:destroy) }
    it { is_expected.to have_many(:tickets).through(:ticket_purchases) }
    it { is_expected.to have_many(:votes).dependent(:destroy) }
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
  end

  describe 'scope and nested attribute' do
    it { should accept_nested_attributes_for :roles }

    describe '.admin' do
      it 'includes users with admin flag' do
        expect(User.admin).to include(user_admin)
      end

      it 'excludes users without admin flag' do
        expect(User.admin).not_to include(user)
      end
    end

    describe '.active' do
      it 'includes users without is_disabled flag' do
        expect(User.active).to include(user)
      end

      it 'excludes users with is_disabled flag' do
        expect(User.active).not_to include(user_disabled)
      end
    end

    describe '.comment_notifiable' do
      let(:cfp_user) { create(:user, role_ids: [cfp_role.id]) }

      it 'includes organizer and cfp user' do
        expect(User.comment_notifiable(conference)).to include(organizer, cfp_user)
      end

      it 'excludes ordinary user' do
        expect(User.comment_notifiable(conference)).not_to include(user)
      end
    end

    describe 'user distribution scopes' do
      it 'scopes recent users' do
        create(:user, last_sign_in_at: Date.today - 3.months + 1.day) # active
        expect(User.recent.count).to eq(1)
      end

      it 'scopes unconfirmed users' do
        create(:user, confirmed_at: nil) # unconfirmed
        expect(User.unconfirmed.count).to eq(1)
      end

      it 'scopes dead users' do
        create(:user, last_sign_in_at: Time.zone.now - 1.year - 1.day) # dead
        expect(User.dead.count).to eq(1)
      end
    end
  end

  describe 'methods' do
    describe '#attended_event?' do
      context 'user has attended to the event' do
        before do
          events_registration.update_attributes(attended: true)
        end

        it 'returns true' do
          expect(user.attended_event?(event1)).to be true
        end
      end

      context 'user did not register for the event' do
        it 'returns false' do
          expect(user.attended_event?(event1)).to be false
        end
      end

      context 'user registered for the event, but did not attend' do
        before do
          events_registration
        end

        it 'returns false' do
          expect(user.attended_event?(event1)).to be false
        end
      end
    end

    describe '#name' do
      it 'returns the username as name if there is not name' do
        user = create(:user, name: nil)
        expect(user.name).to eq(user.username)
      end
    end

    describe '#registered_to_event?' do
      context 'user has registered to event' do
        before do
          events_registration
        end

        it 'returns true' do
          expect(user.registered_to_event?(event1)).to be true
        end
      end

      context 'user has not registered to event' do
        it 'returns false' do
          expect(user.registered_to_event?(event1)).to be false
        end
      end
    end

    describe '#subscribed?' do
      context 'user has subscribed to conference' do
        before { create(:subscription, user: user, conference: conference) }

        it 'returns true' do
          expect(user.subscribed?(conference)).to be true
        end
      end

      context 'user has not subscribed to conference' do
        it 'return false' do
          expect(user.subscribed?(conference)).to be false
        end
      end
    end

    describe '.supports?' do
      context 'user has bought tickets' do
        before { create(:ticket_purchase, user: user, conference: conference) }

        it 'returns true' do
          expect(user.supports?(conference)).to be true
        end
      end

      context 'user has not bought any ticket' do
        it 'return false' do
          expect(user.supports?(conference)).to be false
        end
      end
    end

    describe '.for_ichain_username' do
      before { user.update_attributes(current_sign_in_at: Date.new(2014, 12, 12)) }

      context 'user exists' do
        it 'updates last_sign_in_at of user' do
          expect do
            User.for_ichain_username(user.username, email: user.email)
            user.reload
          end.to change { user.last_sign_in_at }
        end

        it 'updates current_sign_in_at of user' do
          expect do
            User.for_ichain_username(user.username, email: user.email)
            user.reload
          end.to change { user.current_sign_in_at }
        end
      end

      context 'user is disabled' do
        before { user.update_attributes(is_disabled: true) }

        it 'User.for_ichain_username raises exception if user is disabled' do
          expect{ User.for_ichain_username(user.username, email: user.email) }
            .to raise_error(UserDisabled)
        end
      end
    end

    describe '.find_for_database_authentication' do
      context 'login with username' do
        it 'can find user by jumbled username' do
          scrambled_username = user.username.chars.map{|c| rand > 0.5 ? c.capitalize : c}.join
          expect(User.find_for_database_authentication(login: scrambled_username)).to eq(user)
        end
      end

      context 'login with email' do
        it 'can find user by jumbled email' do
          scrambled_email = user.email.chars.map{|c| rand > 0.5 ? c.capitalize : c}.join
          expect(User.find_for_database_authentication(login: scrambled_email)).to eq(user)
        end
      end
    end

    describe '.find_for_auth' do
      let(:auth) do
        OmniAuth::AuthHash.new(provider:    'google',
                               uid:         'google-test-uid-1',
                               info:        {
                                 name:     'new user name',
                                 email:    'test-1@gmail.com',
                                 username: 'newuser'
                               },
                               credentials: {
                                 token:  'mock_token',
                                 secret: 'mock_secret'
                               }
                              )
      end

      context 'user is not signed in' do
        context 'first visit to website' do
          before { @auth_user = User.find_for_auth(auth, nil) }

          it 'initializes new user' do
            expect(@auth_user.new_record?).to be true
          end

          it 'sets name, email, username and password' do
            regex_base64 = %r{^(?:[A-Za-z_\-0-9+\/]{4}\n?)*(?:[A-Za-z_\-0-9+\/]{2}|[A-Za-z_\-0-9+\/]{3}=)?$}
            expect(@auth_user.name).to eq 'new user name'
            expect(@auth_user.email).to eq 'test-1@gmail.com'
            expect(@auth_user.username).to eq 'newuser'
            expect(@auth_user.password).to match regex_base64
          end
        end

        context 'user returns to website' do
          let!(:auth_user) { create(:user, email: 'test-1@gmail.com') }

          it 'finds corresponding user' do
            expect(User.find_for_auth(auth, nil)).to eq auth_user
          end
        end
      end
    end

    describe '#get_roles' do
      let(:conf2_organizer_role) { Role.find_by(name: 'organizer', resource: conference2) }

      before do
        user.update_attributes(role_ids: [organizer_role.id, cfp_role.id, conf2_organizer_role.id])
      end

      it 'returns hash of role and conference' do
        expected_hash = {
          'organizer' => %w[oSC16 oSC15],
          'cfp'       => ['oSC16']
        }

        expect(user.get_roles).to eq expected_hash
      end
    end

    describe '#registered' do
      context 'user has not registered to any conference' do
        it 'returns None' do
          expect(user.registered).to eq 'None'
        end
      end

      context 'user has registered to conferences' do
        before do
          create(:registration, user: user, conference: conference)
          create(:registration, user: user, conference: conference2)
        end

        it 'returns registered conferences title' do
          expect(user.registered).to eq('openSUSE Conference 2016, openSUSE Conference 2015')
        end
      end
    end

    describe '#attended' do
      context 'user has not attended any conference' do
        it 'returns None' do
          expect(user.attended).to eq 'None'
        end
      end

      context 'user has attended conferences' do
        before do
          create(:registration, user: user, conference: conference, attended: true)
          create(:registration, user: user, conference: conference2, attended: true)
        end

        it 'returns attended conferences title' do
          expect(user.attended).to eq('openSUSE Conference 2016, openSUSE Conference 2015')
        end
      end
    end

    describe '#confirmed?' do
      context 'confirmed user' do
        it 'returns true' do
          expect(user.confirmed?).to eq true
        end
      end

      context 'unconfirmed user' do
        before { user.update_attributes(confirmed_at: nil) }

        it 'returns false' do
          expect(user.confirmed?).to eq false
        end
      end
    end

    describe 'proposals methods' do
      let(:submitter) { create(:user) }
      let(:speaker) { create(:user) }
      let(:event1) { create(:event, program: conference.program) }
      let(:event2) { create(:event, program: conference.program) }

      before do
        event1.event_users << create(:event_user, user: submitter, event_role: 'submitter')
        event2.event_users << create(:event_user, user: submitter, event_role: 'submitter')
        event1.event_users << create(:event_user, user: speaker, event_role: 'speaker')
      end

      describe '#proposals' do
        it 'returns events submitted by user' do
          expect(submitter.proposals(conference)).to match [event1, event2]
        end

        it 'returns events in which user is a speaker' do
          expect(speaker.proposals(conference)).to match [event1]
        end
      end

      describe '#proposal_count' do
        it 'returns number of events submitted by user' do
          expect(submitter.proposal_count(conference)).to eq 2
        end

        it 'returns number of events in which the user is a speaker' do
          expect(speaker.proposal_count(conference)).to eq 1
        end
      end
    end
  end

  describe 'rolify' do
    it 'returns the correct role' do
      expect(user_admin.is_admin).to eq(true)
      expect(organizer.roles.first).to eq(organizer_role)
    end

    it 'returns the correct roles' do
      roles = [organizer_role.id, cfp_role.id]
      another_user = create(:user, email: 'participant@example.de')
      another_user.role_ids = roles
      another_user.save

      expect(another_user.roles.length).to eq(2)
      expect(another_user.roles[0]).to eq(organizer_role)
      expect(another_user.roles[1]).to eq(cfp_role)
    end

    describe '#has_cached_role?' do
      describe 'when user has a role' do
        it 'returns true when the user has the role' do
          expect(organizer.has_cached_role?('organizer', conference)).to be true
        end

        it 'returns false when the user does not have the role' do
          user = create(:user, role_ids: cfp_role.id)
          expect(user.has_cached_role?('organizer', conference)).to be false
        end
      end

      it 'returns false when the user does not have a role' do
        user = create(:user, role_ids: [])
        expect(user.has_cached_role?('organizer', conference)).to be false
      end
    end
  end

  describe 'assigns admin attribute' do
    it 'to second user when first user is deleted_user' do
      deleted_user = User.find_by(email: 'deleted@localhost.osem')
      expect(deleted_user.is_admin).to be false

      user_after_deleted = create(:admin)
      expect(user_after_deleted.is_admin).to be true
    end
  end

  describe 'does not assign admin attribute' do
    it 'when first user is not deleted_user' do
      first_user = create(:user)
      expect(first_user.is_admin).to be false

      second_user = create(:user)
      expect(second_user.is_admin).to be false
    end
  end

  describe 'has_many events_registrations' do
    before :each do
      registration1 = create(:registration, user: user, conference: conference)
      registration2 = create(:registration, user: user, conference: another_conference)
      @events_registration1 = create(:events_registration, registration: registration1, event: event1)
      @events_registration2 = create(:events_registration, registration: registration2, event: event2)
    end

    it 'returns all the events the user registered to' do
      expect(user.events_registrations).to eq [@events_registration1, @events_registration2]
    end
  end

  describe '.omniauth_providers' do
    it 'contains providers' do
      # expect(User.omniauth_providers).to eq [:suse, :google, :facebook, :github]
      expect(User.omniauth_providers).to eq [:google, :discourse]
    end
  end
end
