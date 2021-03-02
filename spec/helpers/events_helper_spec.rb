# frozen_string_literal: true

require 'spec_helper'

describe EventsHelper, type: :helper do
  let(:conference) { create(:conference) }
  let(:event) { create(:event_full, program: conference.program) }
  let(:event_schedule) { create(:event_schedule) }
  let(:my_vote) { 3 }
  let(:max_rating) { 5 }
  let(:fraction) { my_vote.to_s + '/' + max_rating.to_s }

  setup do
    allow(event).to receive(:average_rating) { my_vote }
  end

  describe '#registered_text' do
    describe 'returns correct string' do
      it 'when there are no registrations' do
        expect(registered_text(event)).to eq 'Registered: 0'
      end

      it 'when there is 1 registration' do
        event.require_registration = true
        event.max_attendees = 3
        event.registrations << create(:registration, user: event.submitter)
        expect(registered_text(event)).to eq 'Registered: 1/3'
      end
    end
  end

  describe '#canceled_replacement_event_label' do
    describe 'returns nothing' do
      it "when the event isn't cancelled and is not a replacement" do
        event.state = 'confirmed'
        expect(canceled_replacement_event_label(event, nil, 'text-class')).to eq nil
      end

      it 'when the event is canceled' do
        event.state = 'canceled'
        expect(canceled_replacement_event_label(event, nil, 'test-class')).to eq '<span class="label label-danger test-class">CANCELED</span>'
      end

      it 'when the event is a replacement but is not canceled' do
        event.state = 'confirmed'
        allow(event_schedule).to receive(:replacement?) { true }
        expect(canceled_replacement_event_label(event, event_schedule, 'tent-class')).to eq '<span class="label label-info tent-class">REPLACEMENT</span>'
      end

    end
  end

  describe '#rating_tooltip' do
    let(:vote_count) { pluralize(event.voters.length, 'vote') }

    it 'includes the average rating' do
      expect(rating_tooltip(event, max_rating)).to match(fraction)
    end
    it 'includes the vote count' do
      expect(rating_tooltip(event, max_rating)).to match(vote_count)
    end
  end

  describe '#rating_fraction' do
    it 'represents the rating as a fraction of the max' do
      expect(rating_fraction(my_vote, max_rating)).to match(fraction)
    end

    describe 'rating_stars' do
      it 'renders labels for each value of max_rating' do
        expect(
          rating_stars(my_vote, max_rating).scan('<label class="rating').size
        ).to eq(max_rating)
      end

      it 'renders bright labels for each value of vote' do
        expect(
          rating_stars(my_vote, max_rating).scan('<label class="rating bright').size
        ).to eq(my_vote)
      end
    end
  end

  describe '#event_switch_checkbox' do
    let(:result) do
      event_switch_checkbox(event, :is_highlight, conference.short_title)
    end

    it 'should build a switch checkbox' do
      expect(result).to include(
        '<input type="checkbox"',
        'class="switch-checkbox"'
      )
    end

    it 'should use the admin event url' do
      expect(result).to include(
        "url=\"/admin/conferences/#{conference.short_title}/program" \
          "/events/#{event.id}?event%5Bis_highlight%5D=\""
      )
    end
  end

  describe '#event_type_dropdown' do
    let(:event_types) do
      [
        event.event_type,
        create(:event_type, title: 'foo'),
        create(:event_type, title: 'bar')
      ]
    end
    let(:result) do
      event_type_dropdown(event, event_types, conference.short_title)
    end

    it 'builds a bootstrap dropdown list of event types' do
      expect(result).to include(
        '<div class="dropdown">' \
        '<a class="dropdown-toggle" href="#" data-toggle="dropdown">' \
        "<span>#{h event.event_type.title}</span><span class=\"caret\"></span>" \
        '</a><ul class="dropdown-menu">'
      )
      event_types.each do |event_type|
        expect(result).to include(
          '<li><a rel="nofollow" data-method="patch" ' \
          "href=\"/admin/conferences/#{conference.short_title}/program/" \
          "events/#{event.id}?event%5Bevent_type_id%5D=#{event_type.id}\">" \
          "#{h event_type.title}</a></li>"
        )
      end
    end
  end

  describe '#track_dropdown' do
    let(:tracks) do
      [
        event.track,
        create(:track, name: 'foo'),
        create(:track, name: 'bar')
      ]
    end
    let(:result) do
      track_dropdown(event, tracks, conference.short_title)
    end

    it 'builds a bootstrap dropdown list of tracks' do
      expect(result).to include(
        '<div class="dropdown">' \
        '<a class="dropdown-toggle" href="#" data-toggle="dropdown">' \
        "<span>#{h event.track.name}</span><span class=\"caret\"></span>" \
        '</a><ul class="dropdown-menu">'
      )
      tracks.each do |track|
        expect(result).to include(
          '<li><a rel="nofollow" data-method="patch" ' \
          "href=\"/admin/conferences/#{conference.short_title}/program/" \
          "events/#{event.id}?event%5Btrack_id%5D=#{track.id}\">" \
          "#{h track.name}</a></li>"
        )
      end
    end
  end

  describe '#difficulty_dropdown' do
    let(:difficulties) do
      [
        event.difficulty_level,
        create(:difficulty_level, title: 'foo'),
        create(:difficulty_level, title: 'bar')
      ]
    end
    let(:result) do
      difficulty_dropdown(event, difficulties, conference.short_title)
    end

    it 'builds a bootstrap dropdown list of difficulty levels' do
      expect(result).to include(
        '<div class="dropdown">' \
        '<a class="dropdown-toggle" href="#" data-toggle="dropdown">' \
        "<span>#{h event.difficulty_level.title}</span>" \
        '<span class="caret"></span>' \
        '</a><ul class="dropdown-menu">'
      )
      difficulties.each do |difficulty|
        expect(result).to include(
          '<li><a rel="nofollow" data-method="patch" ' \
          "href=\"/admin/conferences/#{conference.short_title}/program/" \
          "events/#{event.id}?event%5Bdifficulty_level_id%5D=#{difficulty.id}\">" \
          "#{h difficulty.title}</a></li>"
        )
      end
    end
  end

  describe '#state_dropdown' do
    let(:conference_id) { conference.short_title }
    let(:email_settings) { conference.email_settings }

    setup do
      allow(event).to receive(:transition_possible?).at_least(:once) { false }
    end

    it 'builds a bootstrap dropdown list of event states' do
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(
        '<div class="dropdown">' \
        '<a class="dropdown-toggle" href="#" data-toggle="dropdown">' \
        "<span>#{h event.state.humanize}</span><span class=\"caret\"></span>" \
        '</a><ul class="dropdown-menu">'
      )
    end

    it 'handles the accept transition' do
      tag = '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/accept\">" \
        'Accept</a></li>'
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).not_to include(tag)

      expect(event).to receive(:transition_possible?).with(:accept) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(tag)
    end

    it 'handles the accept transition without email' do
      expect(event).to receive(:transition_possible?).with(:accept) { true }
      expect(email_settings).to receive(:send_on_accepted?) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(
        '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/accept?send_mail=false\">" \
        'Accept (without email)</a></li>'
      )
    end

    it 'handles the reject transition' do
      tag = '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/reject\">" \
        'Reject</a></li>'
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).not_to include(tag)

      expect(event).to receive(:transition_possible?).with(:reject) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(tag)
    end

    it 'handles the reject transition without email' do
      expect(event).to receive(:transition_possible?).with(:reject) { true }
      expect(email_settings).to receive(:send_on_rejected?) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(
        '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/reject?send_mail=false\">" \
        'Reject (without email)</a></li>'
      )
    end

    it 'handles the restart transition' do
      tag = '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/restart\">" \
        'Start review</a></li>'
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).not_to include(tag)

      expect(event).to receive(:transition_possible?).with(:restart) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(tag)
    end

    it 'handles the confirm transition' do
      tag = '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/confirm\">" \
        'Confirm</a></li>'
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).not_to include(tag)

      expect(event).to receive(:transition_possible?).with(:confirm) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(tag)
    end

    it 'handles the cancel transition' do
      tag = '<li><a rel="nofollow" data-method="patch" ' \
        "href=\"/admin/conferences/#{conference_id}/program/" \
        "events/#{event.id}/cancel\">" \
        'Cancel</a></li>'
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).not_to include(tag)

      expect(event).to receive(:transition_possible?).with(:cancel) { true }
      result = state_dropdown(event, conference_id, email_settings)
      expect(result).to include(tag)
    end
  end
end
