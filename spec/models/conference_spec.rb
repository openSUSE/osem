# encoding: utf-8
# frozen_string_literal: true

# == Schema Information
#
# Table name: conferences
#
#  id                 :bigint           not null, primary key
#  booth_limit        :integer          default(0)
#  color              :string
#  custom_css         :text
#  custom_domain      :string
#  description        :text
#  end_date           :date             not null
#  end_hour           :integer          default(20)
#  events_per_week    :text
#  guid               :string           not null
#  logo_file_name     :string
#  picture            :string
#  registration_limit :integer          default(0)
#  revision           :integer          default(0), not null
#  short_title        :string           not null
#  start_date         :date             not null
#  start_hour         :integer          default(9)
#  ticket_layout      :integer          default("portrait")
#  timezone           :string           not null
#  title              :string           not null
#  use_vdays          :boolean          default(FALSE)
#  use_volunteers     :boolean
#  use_vpositions     :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  organization_id    :integer
#
# Indexes
#
#  index_conferences_on_organization_id  (organization_id)
#
# !/bin/env ruby
require 'spec_helper'

context 'Delegation' do
  subject do
    FactoryBot.create(:conference, start_date: 1.month.from_now, end_date: 2.month.from_now)
  end

  context 'Venue' do
    context 'when venue has not been set' do
      it 'the accessors should be nil' do
        expect(subject.city).to eq(nil)
        expect(subject.country_name).to eq(nil)
        expect(subject.venue_name).to eq(nil)
        expect(subject.venue_street).to eq(nil)
      end
    end

    context 'when venue has been set' do
      it 'should delegate to venue' do
        venue = FactoryBot.create(:venue)
        subject.update(venue: venue)
        expect(subject.city).to eq(venue.city)
        expect(subject.country_name).to eq(venue.country_name)
        expect(subject.venue_name).to eq(venue.name)
        expect(subject.venue_street).to eq(venue.street)
      end
    end
  end
end

describe Conference do

  let(:subject) { create(:conference, start_date: Date.new(2014, 06, 30), end_date: Date.new(2014, 06, 30)) }

  describe '#write_event_distribution_to_db' do

    it 'updates pending conferences' do
      create(:conference,
             start_date: Date.today - 2.weeks,
             end_date:   Date.today - 1.weeks)

      subject.start_date = Date.today + 1.weeks
      subject.end_date = Date.today + 2.weeks

      result = {
        DateTime.now.end_of_week =>
                                    {
                                      confirmed:   0,
                                      unconfirmed: 0,
                                      new:         0,
                                      withdrawn:   0,
                                      canceled:    0,
                                      rejected:    0
                                    },
      }

      Conference.write_event_distribution_to_db
      subject.reload
      expect(subject.events_per_week).to eq(result)
    end

    it 'does not update past conferences' do
      old_conference = create(:conference,
                              start_date: Date.today - 2.weeks,
                              end_date:   Date.today - 1.weeks)

      Conference.write_event_distribution_to_db
      old_conference.reload
      expect(old_conference.events_per_week).to eq({})
    end

    it 'computes the correct result' do
      subject.email_settings = create(:email_settings)
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      subject.save
      create(:cfp, start_date: Date.today - 3.weeks, program: subject.program)

      create(:event, program: subject.program, created_at: Date.today)
      options = {}
      options[:send_mail] = 'false'

      withdrawn = create(:event, program: subject.program)
      withdrawn.withdraw!

      unconfirmed = create(:event, program: subject.program)
      unconfirmed.accept!(options)

      rejected = create(:event, program: subject.program)
      rejected.reject!(options)

      confirmed = create(:event, program: subject.program)
      confirmed.accept!(options)
      confirmed.confirm!

      canceled = create(:event, program: subject.program)
      canceled.accept!(options)
      canceled.cancel!

      Conference.write_event_distribution_to_db

      result = {
        DateTime.now.end_of_week =>
                                    {
                                      confirmed:   1,
                                      unconfirmed: 1,
                                      new:         1,
                                      withdrawn:   1,
                                      canceled:    1,
                                      rejected:    1
                                    },
      }

      subject.reload
      expect(subject.events_per_week).to eq(result)
    end

    it 'does not overwrite old entries' do
      subject.email_settings = create(:email_settings)
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      db_data = {
        DateTime.now.end_of_week - 2.weeks =>
                                              {
                                                confirmed:   1,
                                                unconfirmed: 2,
                                                new:         0,
                                                withdrawn:   0,
                                                canceled:    0,
                                                rejected:    0
                                              },
        DateTime.now.end_of_week - 1.weeks =>
                                              {
                                                confirmed:   3,
                                                unconfirmed: 4,
                                                new:         0,
                                                withdrawn:   0,
                                                canceled:    0,
                                                rejected:    0
                                              },
      }
      subject.events_per_week = db_data
      subject.save
      create(:cfp, start_date: Date.today - 3.weeks, program: subject.program)

      create(:event, program: subject.program, created_at: Date.today)
      unconfirmed = create(:event, program: subject.program)
      confirmed = create(:event, program: subject.program)
      options = {}
      options[:send_mail] = 'false'
      unconfirmed.accept!(options)
      confirmed.accept!(options)
      confirmed.confirm!

      Conference.write_event_distribution_to_db

      result = {
        DateTime.now.end_of_week - 2.weeks =>
                                              {
                                                confirmed:   1,
                                                unconfirmed: 2,
                                                new:         0,
                                                withdrawn:   0,
                                                canceled:    0,
                                                rejected:    0
                                              },
        DateTime.now.end_of_week - 1.weeks =>
                                              {
                                                confirmed:   3,
                                                unconfirmed: 4,
                                                new:         0,
                                                withdrawn:   0,
                                                canceled:    0,
                                                rejected:    0
                                              },
        DateTime.now.end_of_week           =>
                                              {
                                                confirmed:   1,
                                                unconfirmed: 1,
                                                new:         1,
                                                withdrawn:   0,
                                                canceled:    0,
                                                rejected:    0
                                              },
      }

      subject.reload
      expect(subject.events_per_week).to eq(result)
    end
  end

  describe '#get_submissions_data' do
    it 'returns empty hash if there is no cfp or events' do
      expect(subject.get_submissions_data).to eq []
    end

    it 'calculates the correct result with data from database' do
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks

      # Inject last two weeks to database
      db_data = {
        Date.today.end_of_week - 2.weeks => {
          confirmed:   1,
          unconfirmed: 2,
        },
        Date.today.end_of_week - 1.weeks => {
          confirmed:   3,
          unconfirmed: 4,
        }
      }
      subject.events_per_week = db_data

      subject.save
      create(:cfp, start_date: Date.today - 2.weeks, program: subject.program)

      create(:event, program: subject.program, created_at: Date.today - 2.weeks)

      result = [{ name: 'Submitted', data: { 'Wk 1' => 1, 'Wk 2' => 1, 'Wk 3' => 1 } }, { name: 'Confirmed', data: { 'Wk 1' => 1, 'Wk 2' => 3, 'Wk 3' => 0 } }, { name: 'Unconfirmed', data: { 'Wk 1' => 2, 'Wk 2' => 4, 'Wk 3' => 0 } }]
      expect(subject.get_submissions_data).to eq(result)
    end

    it 'calculates the correct result without data from database' do
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      subject.save
      create(:cfp, start_date: Date.today, program: subject.program)
      create(:event, program: subject.program)

      result = [
        { name: 'Submitted', data: { 'Wk 1'=>1 } },
        { name: 'Confirmed', data: { 'Wk 1'=>0 } },
        { name: 'Unconfirmed', data: { 'Wk 1'=>0 } }
      ]
      expect(subject.get_submissions_data).to eq(result)
    end

    it 'pads left correct' do
      subject.email_settings = create(:email_settings)
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      subject.save
      create(:cfp, start_date: Date.today - 3.weeks, program: subject.program)

      create(:event, program: subject.program, created_at: Date.today)
      unconfirmed = create(:event, program: subject.program)
      confirmed = create(:event, program: subject.program)
      options = {}
      options[:send_mail] = 'false'
      unconfirmed.accept!(options)
      confirmed.accept!(options)
      confirmed.confirm!

      result = [
        {
          name: 'Submitted',
          data: { 'Wk 1' => 0, 'Wk 2' => 0, 'Wk 3' => 3 }
        },
        {
          name: 'Confirmed',
          data: { 'Wk 1' => 0, 'Wk 2' => 0, 'Wk 3' => 1 }
        },
        {
          name: 'Unconfirmed',
          data: { 'Wk 1' => 0, 'Wk 2' => 0, 'Wk 3' => 1 }
        }
      ]
      expect(subject.get_submissions_data).to eq(result)
    end

    it 'calculates correct with missing weeks' do
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks

      # Inject last two weeks to database
      db_data = {
        Date.today.end_of_week - 3.weeks => {
          confirmed:   1,
          unconfirmed: 2,
        },
        Date.today.end_of_week - 1.weeks => {
          confirmed:   3,
          unconfirmed: 4,
        }
      }
      subject.events_per_week = db_data

      subject.save
      create(:cfp, start_date: Date.today - 3.weeks, program: subject.program)

      create(:event, program: subject.program, created_at: Date.today - 3.weeks)

      result = [
        {
          name: 'Submitted',
          data: { 'Wk 1' => 1, 'Wk 2' => 1, 'Wk 3' => 1, 'Wk 4' => 1 }
        },
        {
          name: 'Confirmed',
          data: { 'Wk 1' => 1, 'Wk 2' => 0, 'Wk 3' => 3, 'Wk 4' => 0 }
        },
        {
          name: 'Unconfirmed',
          data: { 'Wk 1' => 2, 'Wk 2' => 0, 'Wk 3' => 4, 'Wk 4' => 0 }
        }
      ]
      expect(subject.get_submissions_data).to eq(result)
    end
  end

  describe '#get_top_submitter' do
    let!(:conference) { create(:conference) }
    let!(:organizer) { create(:organizer, resource: conference) }

    it 'calculates correct hash with top submitters' do
      event = create(:event, program: subject.program)
      result = {
        event.submitter => 1
      }
      expect(subject.get_top_submitter).to eq(result)
    end

    it 'returns the submitter ordered by submissions' do
      e1 = create(:event, program: subject.program)

      e2 = create(:event, program: subject.program)
      e3 = create(:event, program: subject.program)
      e4 = create(:event, program: subject.program)

      e3.event_users = [create(:event_user, user: e2.submitter, event_role: 'submitter')]
      e4.event_users = [create(:event_user, user: e2.submitter, event_role: 'submitter')]

      expect(subject.get_top_submitter.values).to eq([3, 1])
      expect(subject.get_top_submitter.keys).to eq([e2.submitter, e1.submitter])
    end

  end

  describe 'program hours and minutes' do
    before(:each) do
      @long = create(:event_type, length: 120)
      @short = create(:event_type, length: 15)
    end

    describe '#actual_program_minutes' do
      it 'calculates correct values with events' do
        create(:event, program: subject.program, event_type: @long)
        create(:event, program: subject.program, event_type: @long)
        create(:event, program: subject.program, event_type: @short)
        create(:event, program: subject.program, event_type: @short)
        result_in_hours = 5
        result_in_minutes = 270
        expect(subject.current_program_hours).to eq(result_in_hours)
        expect(subject.current_program_minutes).to eq(result_in_minutes)
      end

      it 'calculates correct values without events' do
        result = 0
        expect(subject.current_program_minutes).to eq(result)
        expect(subject.current_program_hours).to eq(result)
      end
    end

    describe '#new_program_minutes' do
      it 'calculates correct values with events' do

        create(:event, program: subject.program, event_type: @long, created_at: Time.now - 3.days)
        create(:event, program: subject.program, event_type: @long)
        create(:event, program: subject.program, event_type: @short, created_at: Time.now - 3.days)
        create(:event, program: subject.program, event_type: @short)
        result_in_hours = 2
        result_in_minutes = 135
        expect(subject.new_program_hours(Time.now - 5.minutes)).to eq(result_in_hours)
        expect(subject.new_program_minutes(Time.now - 5.minutes)).to eq(result_in_minutes)
      end

      it 'calculates correct values without events' do
        result = 0
        expect(subject.new_program_minutes(Time.now - 5.minutes)).to eq(result)
        expect(subject.new_program_hours(Time.now - 5.minutes)).to eq(result)
      end
    end
  end

  describe '#difficulty_levels' do
    before do
      subject.email_settings = create(:email_settings)
      @easy = create(:difficulty_level, title: 'Easy', color: '#000000')
      @hard = create(:difficulty_level, title: 'Hard', color: '#ffffff')
    end

    describe '#difficulty_levels_distribution' do

      it 'calculates correct for different difficulty levels' do
        create(:event, program: subject.program, difficulty_level: @easy)
        create(:event, program: subject.program, difficulty_level: @easy)
        create(:event, program: subject.program, difficulty_level: @hard)
        result = {}
        result['Hard'] = {
          'value' => 1,
          'color' => '#FFFFFF',
        }
        result['Easy'] = {
          'value' => 2,
          'color' => '#000000',
        }
        expect(subject.difficulty_levels_distribution).to eq(result)
      end

      it 'calculates correct for one difficulty levels' do
        create(:event, program: subject.program, difficulty_level: @easy)
        result = {}
        result['Easy'] = {
          'value' => 1,
          'color' => '#000000',
        }
        expect(subject.difficulty_levels_distribution).to eq(result)
      end

      it 'calculates correct for no difficulty levels' do
        result = {}
        expect(subject.difficulty_levels_distribution).to eq(result)
      end
    end

    describe '#difficulty_levels_distribution_confirmed' do
      it 'calculates correct for different difficulty levels without confirmed' do
        create(:event, program: subject.program, difficulty_level: @easy)
        create(:event, program: subject.program, difficulty_level: @easy)
        create(:event, program: subject.program, difficulty_level: @hard)
        result = {}

        expect(subject.difficulty_levels_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for different difficulty levels with confirmed' do
        confirmed_easy = create(:event, program: subject.program, difficulty_level: @easy)
        create(:event, program: subject.program, difficulty_level: @easy)
        confirmed_hard = create(:event, program: subject.program, difficulty_level: @hard)

        options = {}
        options[:send_mail] = 'false'
        confirmed_easy.accept!(options)
        confirmed_hard.accept!(options)
        confirmed_easy.confirm!
        confirmed_hard.confirm!

        result = {}
        result['Hard'] = {
          'value' => 1,
          'color' => '#FFFFFF'
        }
        result['Easy'] = {
          'value' => 1,
          'color' => '#000000'
        }
        expect(subject.difficulty_levels_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for one difficulty levels' do
        confirmed = create(:event, program: subject.program, difficulty_level: @easy)
        options = {}
        options[:send_mail] = 'false'
        confirmed.accept!(options)
        confirmed.confirm!

        result = {}
        result['Easy'] = {
          'value' => 1,
          'color' => '#000000',
        }
        expect(subject.difficulty_levels_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for no difficulty levels' do
        result = {}
        expect(subject.difficulty_levels_distribution(:confirmed)).to eq(result)
      end
    end
  end

  describe 'event type distribution' do
    before do
      subject.email_settings = create(:email_settings)
      @workshop = create(:event_type, title: 'Workshop', color: '#000000', program: subject.program)
      @lecture = create(:event_type, title: 'Lecture', color: '#ffffff', program: subject.program)
    end

    describe '#event_type_distribution' do
      it 'calculates correct for different event types' do
        create(:event, program: subject.program, event_type: @workshop)
        create(:event, program: subject.program, event_type: @workshop)
        create(:event, program: subject.program, event_type: @lecture)
        result = {}
        result['Workshop'] = {
          'value' => 2,
          'color' => '#000000',
        }
        result['Lecture'] = {
          'value' => 1,
          'color' => '#FFFFFF',
        }
        expect(subject.event_type_distribution).to eq(result)
      end

      it 'calculates correct for one event types' do
        create(:event, program: subject.program, event_type: @workshop)
        result = {}
        result['Workshop'] = {
          'value' => 1,
          'color' => '#000000',
        }
        expect(subject.event_type_distribution).to eq(result)
      end

      it 'calculates correct for no event types' do
        result = {}
        expect(subject.event_type_distribution).to eq(result)
      end
    end

    describe '#event_type_distribution_confirmed' do
      it 'calculates correct for different event types without confirmed' do
        create(:event, program: subject.program, event_type: @workshop)
        create(:event, program: subject.program, event_type: @workshop)
        create(:event, program: subject.program, event_type: @lecture)
        result = {}

        expect(subject.event_type_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for different event types with confirmed' do
        confirmed_ws = create(:event, program: subject.program, event_type: @workshop)
        create(:event, program: subject.program, event_type: @workshop)
        confirmed_lt = create(:event, program: subject.program, event_type: @lecture)

        options = {}
        options[:send_mail] = 'false'
        confirmed_ws.accept!(options)
        confirmed_lt.accept!(options)
        confirmed_ws.confirm!
        confirmed_lt.confirm!

        result = {}
        result['Lecture'] = {
          'value' => 1,
          'color' => '#FFFFFF'
        }
        result['Workshop'] = {
          'value' => 1,
          'color' => '#000000'
        }
        expect(subject.event_type_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for one event types' do
        confirmed = create(:event, program: subject.program, event_type: @workshop)
        options = {}
        options[:send_mail] = 'false'
        confirmed.accept!(options)
        confirmed.confirm!

        result = {}
        result['Workshop'] = {
          'value' => 1,
          'color' => '#000000',
        }
        expect(subject.event_type_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for no event types' do
        result = {}
        expect(subject.event_type_distribution(:confirmed)).to eq(result)
      end
    end
  end

  describe 'tracks_distribution' do
    before do
      subject.email_settings = create(:email_settings)
      @track_one = create(:track, name: 'Track One', color: '#000000', program: subject.program)
      @track_two = create(:track, name: 'Track Two', color: '#ffffff', program: subject.program)
    end

    describe '#tracks_distribution' do
      it 'calculates correct for different tracks' do
        create(:event, program: subject.program, track: @track_one)
        create(:event, program: subject.program, track: @track_one)
        create(:event, program: subject.program, track: @track_two)
        result = {}
        result['Track One'] = {
          'value' => 2,
          'color' => '#000000',
        }
        result['Track Two'] = {
          'value' => 1,
          'color' => '#FFFFFF',
        }
        expect(subject.tracks_distribution).to eq(result)
      end

      it 'calculates correct for one track' do
        create(:event, program: subject.program, track: @track_one)
        result = {}
        result['Track One'] = {
          'value' => 1,
          'color' => '#000000',
        }
        expect(subject.tracks_distribution).to eq(result)
      end

      it 'calculates correct for no track' do
        result = {}
        expect(subject.tracks_distribution).to eq(result)
      end
    end

    describe '#tracks_distribution_confirmed' do
      it 'calculates correct for different tracks without confirmed' do
        create(:event, program: subject.program, track: @track_one)
        create(:event, program: subject.program, track: @track_one)
        create(:event, program: subject.program, track: @track_two)
        result = {}

        expect(subject.tracks_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for different tracks with confirmed' do
        confirmed_one = create(:event, program: subject.program, track: @track_one)
        create(:event, program: subject.program, track: @track_one)
        confirmed_two = create(:event, program: subject.program, track: @track_two)

        options = {}
        options[:send_mail] = 'false'
        confirmed_one.accept!(options)
        confirmed_two.accept!(options)
        confirmed_one.confirm!
        confirmed_two.confirm!

        result = {}
        result['Track One'] = {
          'value' => 1,
          'color' => '#000000'
        }
        result['Track Two'] = {
          'value' => 1,
          'color' => '#FFFFFF'
        }
        expect(subject.tracks_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for one track' do
        confirmed = create(:event, program: subject.program, track: @track_one)
        options = {}
        options[:send_mail] = 'false'
        confirmed.accept!(options)
        confirmed.confirm!

        result = {}
        result['Track One'] = {
          'value' => 1,
          'color' => '#000000',
        }
        expect(subject.tracks_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for no track' do
        result = {}
        expect(subject.tracks_distribution(:confirmed)).to eq(result)
      end
    end
  end

  describe '#get_active_conferences' do

    it 'returns pending conferences' do
      a = create(:conference,
                 short_title: 'a', start_date: Time.now + 14.days,
                 end_date: Time.now + 21.days)
      b = create(:conference,
                 short_title: 'b', start_date: Time.now + 21.days,
                 end_date: Time.now + 28.days)
      c = create(:conference,
                 short_title: 'c', start_date: Time.now + 21.days,
                 end_date: Time.now + 28.days)
      create(:conference,
             short_title: 'd', start_date: Time.now - 1.year,
             end_date: Time.now - 360.days)
      result = [a, b, c]

      expect(Conference.get_active_conferences_for_dashboard).to match_array(result)
    end

    it 'returns the last two past conferences if there are no pending conferences' do
      subject.start_date = Time.now - 10.days
      subject.end_date = Time.now - 5.days
      subject.save
      c = create(:conference,
                 short_title: 'c', start_date: Time.now - 1.year,
                 end_date: Time.now - 360.days)
      result = [subject, c]

      expect(Conference.get_active_conferences_for_dashboard).to match_array(result)
    end

    it 'returns empty array if there are no conferences' do
      expect(Conference.get_active_conferences_for_dashboard).to match_array([])
    end
  end

  describe '#get_deactive_conferences' do
    it 'returns all conferences without the active conferences' do
      a = create(:conference,  start_date: Time.now - 3.year, end_date: Time.now - 1080.days)
      b = create(:conference,  start_date: Time.now - 2.year, end_date: Time.now - 720.days)
      c = create(:conference, start_date: Time.now - 1.year, end_date: Time.now - 360.days)
      result = [a, b, c]

      expect(Conference.get_conferences_without_active_for_dashboard([subject]))
          .to match_array(result)
    end

    it 'returns all conferences if there are no active conferences' do
      subject.start_date = Time.now - 10.days
      subject.end_date = Time.now - 5.days
      expect(Conference.get_conferences_without_active_for_dashboard([])).to match_array([subject])
    end

    it 'returns empty array if there are no conferences' do
      expect(Conference.get_conferences_without_active_for_dashboard([])).to match_array([])
    end

    it 'returns no conferences if all conferences are pending' do
      expect(Conference.get_conferences_without_active_for_dashboard([subject])).to match_array([])
    end

    it 'return no conferences if there are only two conferences and no pending' do
      a = create(:conference,  start_date: Time.now - 2.year, end_date: Time.now - 720.days)
      b = create(:conference, start_date: Time.now - 1.year, end_date: Time.now - 360.days)
      expect(Conference.get_conferences_without_active_for_dashboard([a, b])).to match_array([])
    end
  end

  describe '#get_submission_line_colors' do
    it ' returns correct values' do
      result = []
      result.push(short_title: 'Submitted', color: 'blue')
      result.push(short_title: 'Confirmed', color: 'green')
      result.push(short_title: 'Unconfirmed', color: 'orange')
      expect(Conference.get_event_state_line_colors).to eq(result)
    end
  end

  describe '#scheduled_event_distribution' do
    let(:conference) { create(:conference) }
    let(:confirmed_unscheduled_event) { create(:event, program: conference.program, state: 'confirmed') }
    let(:confirmed_scheduled_event) { create(:event_scheduled, program: conference.program) }

    it '#scheduled_event_distribution does calculate correct values with events' do
      confirmed_unscheduled_event
      confirmed_scheduled_event
      result = {}
      result['Scheduled'] = { 'value' => 1, 'color' => 'green' }
      result['Unscheduled'] = { 'value' => 1, 'color' => 'red' }
      expect(conference.scheduled_event_distribution).to eq(result)
    end

    it '#scheduled_event_distribution does calculate correct values with no events' do
      result = {}
      result['Scheduled'] = { 'value' => 0, 'color' => 'green' }
      result['Unscheduled'] = { 'value' => 0, 'color' => 'red' }
      expect(conference.scheduled_event_distribution).to eq(result)
    end
  end

  describe '#event_distribution' do

    before(:each) do
      @conference = create(
          :conference,
          email_settings: create(:email_settings))
      @conference.email_settings = create(:email_settings)

      @options = {}
      @options[:send_mail] = 'false'

      create(:event, program: @conference.program)

      withdrawn = create(:event, program: @conference.program)
      withdrawn.withdraw!

      unconfirmed = create(:event, program: @conference.program)
      unconfirmed.accept!(@options)

      rejected = create(:event, program: @conference.program)
      rejected.reject!(@options)

      confirmed = create(:event, program: @conference.program)
      confirmed.accept!(@options)
      confirmed.confirm!

      canceled = create(:event, program: @conference.program)
      canceled.accept!(@options)
      canceled.cancel!

      @result = { 'New' => 1, 'Withdrawn' => 1, 'Unconfirmed' => 1, 'Confirmed' => 1, 'Canceled' => 1, 'Rejected' => 1 }
    end

    it '#event_distribution does calculate correct values with events' do
      expect(@conference.event_distribution).to eq(@result)
    end

    it '#event_distribution does calculate correct values with no events' do
      @conference.program.events.clear
      expect(@conference.event_distribution).to eq({})
    end

    it 'event_distribution does calculate correct values with just a new event' do
      conference = create(:conference)
      create(:event, program: conference.program)
      result = { 'New' => 1, 'Withdrawn' => 0, 'Unconfirmed' => 0, 'Confirmed' => 0, 'Canceled' => 0, 'Rejected' => 0 }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an withdrawn event' do
      conference = create(:conference)
      event = create(:event, program: conference.program)
      event.withdraw!
      result = { 'New' => 0, 'Withdrawn' => 1, 'Unconfirmed' => 0, 'Confirmed' => 0, 'Canceled' => 0, 'Rejected' => 0 }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an unconfirmed event' do
      conference = create(:conference)
      event = create(:event, program: conference.program)
      event.accept!(@options)
      result = { 'New' => 0, 'Withdrawn' => 0, 'Unconfirmed' => 1, 'Confirmed' => 0, 'Canceled' => 0, 'Rejected' => 0 }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an rejected event' do
      conference = create(:conference)
      event = create(:event, program: conference.program)
      event.reject!(@options)
      result = { 'New' => 0, 'Withdrawn' => 0, 'Unconfirmed' => 0, 'Confirmed' => 0, 'Canceled' => 0, 'Rejected' => 1 }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an confirmed event' do
      conference = create(:conference)
      conference.email_settings = create(:email_settings)
      event = create(:event, program: conference.program)
      event.accept!(@options)
      event.confirm!
      result = { 'New' => 0, 'Withdrawn' => 0, 'Unconfirmed' => 0, 'Confirmed' => 1, 'Canceled' => 0, 'Rejected' => 0 }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an canceled event' do
      conference = create(:conference)
      event = create(:event, program: conference.program)
      event.accept!(@options)
      event.cancel!
      result = { 'New' => 0, 'Withdrawn' => 0, 'Unconfirmed' => 0, 'Confirmed' => 0, 'Canceled' => 1, 'Rejected' => 0 }
      expect(conference.event_distribution).to eq(result)
    end

    it 'self#event_distribution does calculate correct values' do
      expect(Conference.event_distribution).to eq(@result)
    end

    it 'self#event_distribution does calculate correct values with no events' do
      @conference.program.events.clear
      expect(Conference.event_distribution).to eq({})
    end

    it 'self#event_distribution does calculate correct values with just a new event' do
      @conference.program.events.clear
      create(:event, program: @conference.program)
      result = { 'New' => 1, 'Withdrawn' => 0, 'Unconfirmed' => 0, 'Confirmed' => 0, 'Canceled' => 0, 'Rejected' => 0 }
      expect(Conference.event_distribution).to eq(result)
    end

    it 'self#event_distribution does calculate correct values
                      with just a new events from different conferences' do
      create(:event, program: @conference.program)
      result = { 'New' => 2, 'Withdrawn' => 1, 'Unconfirmed' => 1, 'Confirmed' => 1, 'Canceled' => 1, 'Rejected' => 1 }
      expect(Conference.event_distribution).to eq(result)
    end
  end

  describe 'self#event_distribution' do
    let!(:conference) { create(:conference) }
    let!(:organizer) { create(:organizer, resource: conference) }

    it 'self#user_distribution calculates correct values with user' do
      result = {}
      result['Active'] = { 'color' => 'green', 'value' => 1 }
      result['Unconfirmed'] = { 'color' => 'red', 'value' => 1 }
      result['Dead'] = { 'color' => 'black', 'value' => 1 }

      expect(
        Conference.calculate_user_distribution_hash(1, 1, 1)
      ).to eq(result)
    end
  end

  describe '#get_status' do

    before(:each) do
      # Setup positive result hash
      @result = {}
      @result['registration'] = true
      @result['cfp'] = true
      @result['venue'] = true
      @result['rooms'] = true
      @result['tracks'] = true
      @result['event_types'] = true
      @result['difficulty_levels'] = true
      @result['splashpage'] = true

      # Setup negative result hash
      @result_false = Hash.new
      @result.each { |key, value| @result_false[key] = !value }

      @result['short_title'] = @result_false['short_title'] = subject.short_title
      @result['process'] = 100.to_s
      @result_false['process'] = 0.to_s
    end

    it 'calculates correct for new conference' do
      subject.venue = nil
      subject.program.tracks = []
      subject.program.event_types = []
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration' do
      subject.registration_period = create(:registration_period,
                                           start_date: subject.end_date - 14,
                                           end_date: subject.end_date, conference: subject)
      subject.venue = nil
      subject.program.event_types = []
      subject.program.tracks = []
      subject.program.event_types = []
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['registration'] = true
      @result_false['process'] = 12.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp' do
      subject.registration_period = create(:registration_period,
                                           start_date: subject.end_date - 14,
                                           end_date: subject.end_date, conference: subject)
      create(:cfp, program: subject.program)
      subject.venue = nil
      subject.program.tracks = []
      subject.program.event_types = []
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['process'] = 25.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue' do
      expect(subject.end_date).to eq Date.new(2014, 06, 30)
      subject.registration_period = create(:registration_period,
                                           start_date: subject.end_date - 14,
                                           end_date: subject.end_date, conference: subject)
      create(:cfp, program: subject.program)
      subject.venue = create(:venue, conference: subject)
      subject.venue.rooms = []
      subject.program.tracks = []
      subject.program.event_types = []
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['process'] = 37.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue, rooms' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14, conference: subject)
      create(:cfp, program: subject.program)
      subject.venue = create(:venue, conference: subject)
      subject.venue.rooms = [create(:room, venue: subject.venue)]
      subject.program.tracks = []
      subject.program.event_types = []
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['process'] = 50.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue, rooms, tracks' do
      subject.venue = create(:venue, conference: subject)
      subject.venue.rooms = [create(:room, venue: subject.venue)]
      subject.program.tracks = [create(:track)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14, conference: subject)
      create(:cfp, program: subject.program)
      subject.program.event_types = []
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['tracks'] = true
      @result_false['process'] = 62.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp,
                                      venue, rooms, tracks, event_types' do
      subject.program.tracks = [create(:track)]
      subject.program.event_types = [create(:event_type)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14, conference: subject)
      create(:cfp, program: subject.program)
      subject.venue = create(:venue, conference: subject)
      subject.venue.rooms = [create(:room, venue: subject.venue)]
      subject.program.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['tracks'] = true
      @result_false['event_types'] = true
      @result_false['process'] = 75.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with all mandatory options' do
      subject.program.tracks = [create(:track)]
      subject.program.event_types = [create(:event_type)]
      subject.program.difficulty_levels = [create(:difficulty_level)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14, conference: subject)
      create(:cfp, program: subject.program)
      subject.venue = create(:venue, conference: subject)
      subject.venue.rooms = [create(:room, venue: subject.venue)]
      subject.splashpage = create(:splashpage, public: true)

      expect(subject.get_status).to eq(@result)
    end
  end

  describe '#registration_weeks' do

    it 'calculates new year' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2013, 12, 31),
                                           end_date:   Date.new(2013, 12, 30) + 6)
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is one if start and end are 6 days apart' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 6, conference: subject)
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is one if start and end date are the same' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26), conference: subject)
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is two if start and end are 10 days apart' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 17),
                                           end_date: Date.new(2014, 05, 15) + 10, conference: subject)
      expect(subject.registration_weeks).to eq(2)
    end
  end

  describe '#cfp_weeks' do

    it 'calculates new year' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2013, 12, 30)
      cfp.end_date = Date.new(2013, 12, 30) + 6
      cfp.save!
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is one if start and end are 6 days apart' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 6
      cfp.save!
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is one if start and end are the same date' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26)
      cfp.save!
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is two if start and end are 10 days apart' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 10
      cfp.save!
      expect(subject.cfp_weeks).to eq(2)
    end
  end

  describe '#get_submissions_per_week' do

    it 'does calculate correct if cfp start date is altered' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) - 7)]
      expect(subject.get_submissions_per_week.values).to eq([1, 1, 1, 1, 1])
    end

    it 'does calculate correct if cfp end date is altered' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 28)]
      expect(subject.get_submissions_per_week.values).to eq([0, 0, 0, 0, 1])
    end

    it 'pads with zeros if there are no submissions' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      expect(subject.get_submissions_per_week.values).to eq([0, 0, 0, 0])
    end

    it 'summarized correct if there are no submissions in one week' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 28
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 28)]
      expect(subject.get_submissions_per_week.values).to eq([0, 1, 2, 2, 3])
    end

    it 'summarized correct if there are submissions every week except the first' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      expect(subject.get_submissions_per_week.values).to eq([0, 1, 2, 2])
    end

    it 'summarized correct if there are submissions every week' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      expect(subject.get_submissions_per_week).to eq(
        'Wk 1' => 1, 'Wk 2' => 2, 'Wk 3' => 3, 'Wk 4' => 3
      )
    end

    it 'pads left' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 21)]
      expect(subject.get_submissions_per_week.values).to eq([0, 0, 0, 1])
    end

    it 'pads middle' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26) + 21)]
      expect(subject.get_submissions_per_week.values).to eq([1, 1, 1, 2])
    end

    it 'pads right' do
      cfp = create(:cfp, program: subject.program)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      cfp.save!
      subject.program.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      expect(subject.get_submissions_per_week.values).to eq([1, 1, 1, 1])
    end
  end

  describe '#get_registrations_per_week' do

    it 'pads with zeros if there are no registrations' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 21, conference: subject)

      expect(subject.get_registrations_per_week.values).to eq([0, 0, 0, 0])
    end

    it 'summarized correct if there are no registrations in one week' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 28, conference: subject)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)

      expect(subject.get_registrations_per_week.values).to eq([0, 1, 2, 2, 3])
    end

    it 'returns [1] if there is one registration on the first day' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 7, conference: subject)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      expect(subject.get_registrations_per_week.values).to eq([1, 1])
    end

    it 'summarized correct if there are registrations every week' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 21, conference: subject)

      create(:registration, conference: subject, created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)

      expect(subject.get_registrations_per_week.values).to eq([1, 2, 3, 3])
    end

    it 'summarized correct if there are registrations every week except the first' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 28, conference: subject)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)

      expect(subject.get_registrations_per_week.values).to eq([0, 1, 2, 2, 3])
    end

    it 'pads left' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 35, conference: subject)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 21)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 35)

      expect(subject.get_registrations_per_week.values).to eq([0, 0, 0, 1, 2, 3])
    end

    it 'pads middle' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 35, conference: subject)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 35)

      expect(subject.get_registrations_per_week.values).to eq([1, 1, 1, 1, 1, 2])
    end

    it 'pads right' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 35, conference: subject)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)

      expect(subject.get_registrations_per_week.values).to eq([1, 2, 2, 2, 2, 2])
    end
  end

  describe '#pending?' do

    context 'is pending' do

      it '#pending? is true' do
        subject.start_date = Date.today + 10
        expect(subject.pending?).to be true
      end
    end

    context 'is not pending' do

      it '#pending? is false' do
        subject.start_date = Date.today - 10
        expect(subject.pending?).to be false
      end
    end
  end

  describe '#registration_open?' do

    context 'closed registration' do

      it '#registration_open? is false' do
        expect(subject.registration_open?).to be false
      end
    end

    context 'open registration' do

      before do
        subject.end_date = Date.today + 7
        enrollment = create(:registration_period,
                            start_date: Date.today - 1,
                            end_date: Date.today + 7, conference: subject)
        subject.registration_period = enrollment
      end

      it '#registration_open? is true' do
        expect(subject.registration_open?).to be true
      end
    end
  end

  describe '#cfp_open?' do

    context 'closed cfp' do

      it '#cfp_open? is false' do
        expect(subject.program.cfp_open?).to be false
      end

    end

    context 'open cfp' do

      before do
        create(:cfp, program: subject.program)
      end

      it '#registration_open? is true' do
        expect(subject.program.cfp_open?).to be true
      end
    end
  end

  describe '#user_registered?' do

    # It is necessary to use bang version of let to build roles before user
    let!(:conference) { create(:conference) }
    let!(:organizer) { create(:organizer, resource: conference) }
    let(:user) { create(:user) }

    context 'user not registered' do
      it '#user_registered? is false' do
        expect(subject.user_registered? user).to be false
      end
    end

    context 'user is nil' do
      it '#user_registered? is false' do
        expect(subject.user_registered? user).to be false
      end
    end

    context 'user registered' do
      before do
        registration = create(:registration)
        subject.registrations << registration
        user.registrations << registration
      end

      it '#user_registered? is true' do
        expect(subject.user_registered? user).to be true
      end
    end
  end

  describe 'registration_limit_exceeded?' do
    context 'limit less than 0' do
      before do
        subject.registration_limit = -1
      end
      it '#registration_limit_exceeded? is false' do
        expect(subject.registration_limit_exceeded?).to be false
      end
    end

    context 'limit is 0' do
      before do
        subject.registration_limit = 0
      end
      it '#registration_limit_exceeded? is false' do
        expect(subject.registration_limit_exceeded?).to be false
      end
    end

    context 'limit is 1' do
      before do
        subject.registration_limit = 1
      end
      context 'there are no registration' do
        it '#registration_limit_exceeded? is false' do
          expect(subject.registration_limit_exceeded?).to be false
        end
      end

      context 'there are 1 registration' do
        before do
          registration1 = create(:registration)
          subject.registrations << registration1
        end

        it '#registration_limit_exceeded? is true' do
          expect(subject.registration_limit_exceeded?).to be true
        end
      end
    end
  end

  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:conference)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end

    it 'is not valid without a short title' do
      should validate_presence_of(:short_title)
    end

    it 'is not valid without a start date' do
      should validate_presence_of(:start_date)
    end

    it 'is not valid without an end date' do
      should validate_presence_of(:end_date)
    end

    it 'is not valid without a start date' do
      should validate_presence_of(:start_hour)
    end

    it 'is not valid without an end date' do
      should validate_presence_of(:end_hour)
    end

    it 'is not valid without a ticket_layout' do
      should validate_presence_of(:ticket_layout)
    end

    it 'is not valid with a duplicate short title' do
      should validate_uniqueness_of(:short_title)
    end

    it 'is valid with a short title that contains a-zA-Z0-9_-' do
      should allow_value('abc_xyz-ABC-XYZ-012_89').for(:short_title)
    end

    it 'is not valid with a short title that contains special characters' do
      should_not allow_value('&%§!?äÄüÜ/()').for(:short_title)
    end

    it 'is not valid with a registration limit as float' do
      should_not allow_value(0.5).for(:registration_limit)
    end

    it 'is not valid with a negative registration limit' do
      should_not allow_value(-1).for(:registration_limit)
    end

    describe 'valid_date_range?' do

      it 'is not valid if start date is greater than end date' do
        expect(subject.start_date).to be <= subject.end_date
      end
    end

    describe 'valid_times_range?' do

      it 'is not valid if start hour is lower than 0' do
        expect(subject.start_hour).to be >= 0
      end

      it 'is not valid if end hour is lower or equal than start hour' do
        expect(subject.start_hour).to be < subject.end_hour
      end

      it 'is not valid if end hour is greater than 24' do
        expect(subject.end_hour).to be <= 24
      end
    end

    describe 'before create callbacks' do

      it 'has an email setting after creation' do
        expect(subject.email_settings).not_to be_nil
      end

      it 'has a guid after creation' do
        expect(subject.guid).not_to be_nil
      end
    end
  end

  describe 'after_create' do
    let(:conference) { create(:conference) }

    it 'calls back to create free ticket' do
      conference.save
      conference.run_callbacks :create
      free_ticket = conference.tickets.first
      expect(free_ticket.price_cents).to eq(0)
    end
  end

  describe 'after_update' do
    let(:conference) { create(:conference) }
    let(:scheduled_event_before_conference) { create(:event_scheduled, program: conference.program, hour: conference.start_date + conference.start_hour.hours) }
    let(:scheduled_event_after_conference) { create(:event_scheduled, program: conference.program, hour: conference.start_date + conference.end_hour.hours - 1.hour) }
    let!(:scheduled_event_during_conference) { create(:event_scheduled, program: conference.program, hour: conference.start_date + conference.start_hour.hours + 3.hours) }

    it 'delete event schedules that are not in hour ranges, when conference start hour is updated' do
      scheduled_event_before_conference
      conference.start_hour = conference.start_hour + 1
      expect{ conference.save }.to change{ EventSchedule.count }.from(2).to(1)
    end

    it 'delete event schedules that are not in hour ranges, when conference end hour is updated' do
      scheduled_event_after_conference
      conference.end_hour = conference.end_hour - 2
      expect{ conference.save }.to change{ EventSchedule.count }.from(2).to(1)
    end
  end

  describe '#revision' do
    let(:track) { create(:track, program: subject.program) }
    let(:event) { create(:event, program: subject.program, track: track) }
    let(:venue) { create(:venue, conference: subject) }
    let(:room)  { create(:room, venue: venue) }

    it 'for change in conference' do
      subject.title = 'changed'
      expect{ subject.save }.to change { subject.revision }.by(1)
    end

    it 'for change in event' do
      event.title = 'changed'
      expect{ event.save }.to change { subject.revision }.by(1)
    end

    it 'for change in track' do
      track.name = 'changed'
      expect{ track.save }.to change { subject.revision }.by(1)
    end

    it 'for change in room' do
      room.name = 'changed'
      expect{ room.save }.to change { subject.revision }.by(1)
    end
  end

  describe '.upcoming' do
    let!(:upcoming_conference) { create(:conference) }
    let!(:past_conference) { create(:conference, start_date: Date.current - 1.days, end_date: Date.current - 1.days) }
    subject { Conference.upcoming }

    it { is_expected.to eq [upcoming_conference] }
  end

  describe '.past' do
    let!(:upcoming_conference) { create(:conference) }
    let!(:past_conference1) { create(:conference, start_date: Date.current - 1.days, end_date: Date.current - 1.days) }
    let!(:past_conference2) { create(:conference, start_date: Date.current - 2.days, end_date: Date.current - 1.days) }
    subject { Conference.past }

    it { is_expected.to eq [past_conference1, past_conference2] }
  end

  it 'should have a picture format for tickets' do
    expect(create(:conference).picture.ticket.url)
  end
end
