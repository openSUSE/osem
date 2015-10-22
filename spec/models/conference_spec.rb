#!/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe Conference do
  let(:subject) { create(:conference, end_date: '2014-06-30') }

  describe '#write_event_distribution_to_db' do
    it 'updates pending conferences' do
      create(:conference,
             start_date: Date.today - 2.weeks,
             end_date: Date.today - 1.weeks)

      subject.start_date = Date.today + 1.weeks
      subject.end_date = Date.today + 2.weeks

      result = {
        DateTime.now.end_of_week =>
          {
            confirmed: 0,
            unconfirmed: 0,
            new: 0,
            withdrawn: 0,
            canceled: 0,
            rejected: 0
          },
      }

      Conference.write_event_distribution_to_db
      subject.reload
      expect(subject.events_per_week).to eq(result)
    end

    it 'does not update past conferences' do
      old_conference = create(:conference,
                              start_date: Date.today - 2.weeks,
                              end_date: Date.today - 1.weeks)

      Conference.write_event_distribution_to_db
      old_conference.reload
      expect(old_conference.events_per_week).to eq({})
    end

    it 'computes the correct result' do
      subject.email_settings = create(:email_settings)
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      subject.save
      subject.call_for_paper = create(:call_for_paper, start_date: Date.today - 3.weeks)

      create(:event, conference: subject, created_at: Date.today)
      options = {}
      options[:send_mail] = 'false'

      withdrawn = create(:event, conference: subject)
      withdrawn.withdraw!

      unconfirmed = create(:event, conference: subject)
      unconfirmed.accept!(options)

      rejected = create(:event, conference: subject)
      rejected.reject!(options)

      confirmed = create(:event, conference: subject)
      confirmed.accept!(options)
      confirmed.confirm!

      canceled = create(:event, conference: subject)
      canceled.accept!(options)
      canceled.cancel!

      Conference.write_event_distribution_to_db

      result = {
        DateTime.now.end_of_week =>
          {
            confirmed: 1,
            unconfirmed: 1,
            new: 1,
            withdrawn: 1,
            canceled: 1,
            rejected: 1
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
            confirmed: 1,
            unconfirmed: 2,
            new: 0,
            withdrawn: 0,
            canceled: 0,
            rejected: 0
          },
        DateTime.now.end_of_week - 1.weeks =>
          {
            confirmed: 3,
            unconfirmed: 4,
            new: 0,
            withdrawn: 0,
            canceled: 0,
            rejected: 0
          },
      }
      subject.events_per_week = db_data
      subject.save
      subject.call_for_paper = create(:call_for_paper, start_date: Date.today - 3.weeks)

      create(:event, conference: subject, created_at: Date.today)
      unconfirmed = create(:event, conference: subject)
      confirmed = create(:event, conference: subject)
      options = {}
      options[:send_mail] = 'false'
      unconfirmed.accept!(options)
      confirmed.accept!(options)
      confirmed.confirm!

      Conference.write_event_distribution_to_db

      result = {
        DateTime.now.end_of_week - 2.weeks =>
          {
            confirmed: 1,
            unconfirmed: 2,
            new: 0,
            withdrawn: 0,
            canceled: 0,
            rejected: 0
          },
        DateTime.now.end_of_week - 1.weeks =>
          {
            confirmed: 3,
            unconfirmed: 4,
            new: 0,
            withdrawn: 0,
            canceled: 0,
            rejected: 0
          },
        DateTime.now.end_of_week =>
          {
            confirmed: 1,
            unconfirmed: 1,
            new: 1,
            withdrawn: 0,
            canceled: 0,
            rejected: 0
          },
      }

      subject.reload
      expect(subject.events_per_week).to eq(result)
    end
  end

  describe '#get_submissions_data' do
    it 'returns emtpy hash if there is no cfp or events' do
      expect(subject.get_submissions_data).to eq({})
    end

    it 'calculates the correct result with data from database' do
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks

      # Inject last two weeks to database
      db_data = {
        Date.today.end_of_week - 2.weeks => {
          confirmed: 1,
          unconfirmed: 2,
        },
        Date.today.end_of_week - 1.weeks => {
          confirmed: 3,
          unconfirmed: 4,
        }
      }
      subject.events_per_week = db_data

      subject.save
      subject.call_for_paper = create(:call_for_paper, start_date: Date.today - 2.weeks)

      create(:event, conference: subject, created_at: Date.today - 2.weeks)

      result = {
        'Submitted' => [1, 1, 1],
        'Confirmed' => [1, 3, 0],
        'Unconfirmed' => [2, 4, 0],
        'Weeks' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      }
      expect(subject.get_submissions_data).to eq(result)
    end

    it 'calculates the correct result without data from database' do
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      subject.save
      subject.call_for_paper = create(:call_for_paper, start_date: Date.today)
      create(:event, conference: subject)

      result = {
        'Submitted' => [1],
        'Confirmed' => [0],
        'Unconfirmed' => [0],
        'Weeks' => [1, 2, 3, 4, 5, 6, 7, 8]
      }
      expect(subject.get_submissions_data).to eq(result)
    end

    it 'pads left correct' do
      subject.email_settings = create(:email_settings)
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks
      subject.save
      subject.call_for_paper = create(:call_for_paper, start_date: Date.today - 3.weeks)

      create(:event, conference: subject, created_at: Date.today)
      unconfirmed = create(:event, conference: subject)
      confirmed = create(:event, conference: subject)
      options = {}
      options[:send_mail] = 'false'
      unconfirmed.accept!(options)
      confirmed.accept!(options)
      confirmed.confirm!

      result = {
        'Submitted' => [0, 0, 3],
        'Confirmed' => [0, 0, 1],
        'Unconfirmed' => [0, 0, 1],
        'Weeks' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      }
      expect(subject.get_submissions_data).to eq(result)
    end

    it 'calculates correct with missing weeks' do
      subject.start_date = Date.today + 6.weeks
      subject.end_date = Date.today + 7.weeks

      # Inject last two weeks to database
      db_data = {
        Date.today.end_of_week - 3.weeks => {
          confirmed: 1,
          unconfirmed: 2,
        },
        Date.today.end_of_week - 1.weeks => {
          confirmed: 3,
          unconfirmed: 4,
        }
      }
      subject.events_per_week = db_data

      subject.save
      subject.call_for_paper = create(:call_for_paper, start_date: Date.today - 3.weeks)

      create(:event, conference: subject, created_at: Date.today - 3.weeks)

      result = {
        'Submitted' => [1, 1, 1, 1],
        'Confirmed' => [1, 0, 3, 0],
        'Unconfirmed' => [2, 0, 4, 0],
        'Weeks' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      }
      expect(subject.get_submissions_data).to eq(result)
    end
  end

  describe '#get_top_submitter' do
    let!(:conference) { create(:conference) }
    let!(:organizer_role) { create(:organizer_role, resource: conference) }
    let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

    it 'calculates correct hash with top submitters' do
      event = create(:event, conference: subject)
      result = {
        event.submitter => 1
      }
      expect(subject.get_top_submitter).to eq(result)
    end

    it 'returns the submitter ordered by submissions' do
      e1 = create(:event, conference: subject)

      e2 = create(:event, conference: subject)
      e3 = create(:event, conference: subject)
      e4 = create(:event, conference: subject)

      e3.event_users = [create(:event_user, user: e2.submitter, event_role: 'submitter')]
      e4.event_users = [create(:event_user, user: e2.submitter, event_role: 'submitter')]

      expect(subject.get_top_submitter.values).to eq([3, 1])
      expect(subject.get_top_submitter.keys).to eq([e2.submitter, e1.submitter])
    end
  end

  describe '#get_targets' do
    it 'returns 0 if there is no registration' do
      target = build(:target, target_count: 10, unit: Target.units[:registrations])
      subject.targets = [target]
      result = {
        "10 Registrations by #{target.due_date}" => '0'
      }
      expect(subject.get_targets(Target.units[:registrations])).to eq(result)
    end

    it 'returns 10 if there is 1 registration of 10' do
      target = build(:target, target_count: 10, unit: Target.units[:registrations])
      subject.targets = [target]
      subject.registrations = [create(:registration)]
      result = {
        "10 Registrations by #{target.due_date}" => '10'
      }
      expect(subject.get_targets(Target.units[:registrations])).to eq(result)
    end

    it 'returns an empty hash if there is no target' do
      expect(subject.get_targets(Target.units[:registrations])).to eq({})
    end

    it 'returns 0 if there is no submission' do
      target = build(:target, target_count: 10, unit: Target.units[:submissions])
      subject.targets = [target]
      result = {
        "10 Submissions by #{target.due_date}" => '0'
      }
      expect(subject.get_targets(Target.units[:submissions])).to eq(result)
    end

    it 'returns 10 if there is 1 submissions of 10' do
      target = build(:target, target_count: 10, unit: Target.units[:submissions])
      subject.targets = [target]
      subject.events = [create(:event)]
      result = {
        "10 Submissions by #{target.due_date}" => '10'
      }
      expect(subject.get_targets(Target.units[:submissions])).to eq(result)
    end

    it 'returns 0 if there is no program minute' do
      target = build(:target, target_count: 300, unit: Target.units[:program_minutes])
      subject.targets = [target]
      result = {
        "300 Program minutes by #{target.due_date}" => '0'
      }
      expect(subject.get_targets(Target.units[:program_minutes])).to eq(result)
    end

    it 'returns 10 if there is 30 program minutes of 300' do
      target = build(:target, target_count: 300, unit: Target.units[:program_minutes])
      subject.targets = [target]
      subject.events = [create(:event)]
      result = {
        "300 Program minutes by #{target.due_date}" => '10'
      }
      expect(subject.get_targets(Target.units[:program_minutes])).to eq(result)
    end
  end

  describe 'program hours and minutes' do
    before(:each) do
      @long = create(:event_type, length: 100)
      @short = create(:event_type, length: 10)
    end

    describe '#actual_program_minutes' do
      it 'calculates correct values with events' do
        create(:event, conference: subject, event_type: @long)
        create(:event, conference: subject, event_type: @long)
        create(:event, conference: subject, event_type: @short)
        create(:event, conference: subject, event_type: @short)
        result_in_hours = 4
        result_in_minutes = 220
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
        create(:event, conference: subject, event_type: @long, created_at: Time.now - 3.days)
        create(:event, conference: subject, event_type: @long)
        create(:event, conference: subject, event_type: @short, created_at: Time.now - 3.days)
        create(:event, conference: subject, event_type: @short)
        result_in_hours = 2
        result_in_minutes = 110
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
        create(:event, conference: subject, difficulty_level: @easy)
        create(:event, conference: subject, difficulty_level: @easy)
        create(:event, conference: subject, difficulty_level: @hard)
        result = {}
        result['Hard'] = {
          'value' => 1,
          'color' => '#ffffff',
        }
        result['Easy'] = {
          'value' => 2,
          'color' => '#000000',
        }
        expect(subject.difficulty_levels_distribution).to eq(result)
      end

      it 'calculates correct for one difficulty levels' do
        create(:event, conference: subject, difficulty_level: @easy)
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
        create(:event, conference: subject, difficulty_level: @easy)
        create(:event, conference: subject, difficulty_level: @easy)
        create(:event, conference: subject, difficulty_level: @hard)
        result = {}

        expect(subject.difficulty_levels_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for different difficulty levels with confirmed' do
        confirmed_easy = create(:event, conference: subject, difficulty_level: @easy)
        create(:event, conference: subject, difficulty_level: @easy)
        confirmed_hard = create(:event, conference: subject, difficulty_level: @hard)

        options = {}
        options[:send_mail] = 'false'
        confirmed_easy.accept!(options)
        confirmed_hard.accept!(options)
        confirmed_easy.confirm!
        confirmed_hard.confirm!

        result = {}
        result['Hard'] = {
          'value' => 1,
          'color' => '#ffffff'
        }
        result['Easy'] = {
          'value' => 1,
          'color' => '#000000'
        }
        expect(subject.difficulty_levels_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for one difficulty levels' do
        confirmed = create(:event, conference: subject, difficulty_level: @easy)
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
      @workshop = create(:event_type, title: 'Workshop', color: '#000000', conference: subject)
      @lecture = create(:event_type, title: 'Lecture', color: '#ffffff', conference: subject)
    end

    describe '#event_type_distribution' do
      it 'calculates correct for different event types' do
        create(:event, conference: subject, event_type: @workshop)
        create(:event, conference: subject, event_type: @workshop)
        create(:event, conference: subject, event_type: @lecture)
        result = {}
        result['Workshop'] = {
          'value' => 2,
          'color' => '#000000',
        }
        result['Lecture'] = {
          'value' => 1,
          'color' => '#ffffff',
        }
        expect(subject.event_type_distribution).to eq(result)
      end

      it 'calculates correct for one event types' do
        create(:event, conference: subject, event_type: @workshop)
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
        create(:event, conference: subject, event_type: @workshop)
        create(:event, conference: subject, event_type: @workshop)
        create(:event, conference: subject, event_type: @lecture)
        result = {}

        expect(subject.event_type_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for different event types with confirmed' do
        confirmed_ws = create(:event, conference: subject, event_type: @workshop)
        create(:event, conference: subject, event_type: @workshop)
        confirmed_lt = create(:event, conference: subject, event_type: @lecture)

        options = {}
        options[:send_mail] = 'false'
        confirmed_ws.accept!(options)
        confirmed_lt.accept!(options)
        confirmed_ws.confirm!
        confirmed_lt.confirm!

        result = {}
        result['Lecture'] = {
          'value' => 1,
          'color' => '#ffffff'
        }
        result['Workshop'] = {
          'value' => 1,
          'color' => '#000000'
        }
        expect(subject.event_type_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for one event types' do
        confirmed = create(:event, conference: subject, event_type: @workshop)
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
      @track_one = create(:track, name: 'Track One', color: '#000000')
      @track_two = create(:track, name: 'Track Two', color: '#ffffff')
    end

    describe '#tracks_distribution' do
      it 'calculates correct for different tracks' do
        create(:event, conference: subject, track: @track_one)
        create(:event, conference: subject, track: @track_one)
        create(:event, conference: subject, track: @track_two)
        result = {}
        result['Track One'] = {
          'value' => 2,
          'color' => '#000000',
        }
        result['Track Two'] = {
          'value' => 1,
          'color' => '#ffffff',
        }
        expect(subject.tracks_distribution).to eq(result)
      end

      it 'calculates correct for one track' do
        create(:event, conference: subject, track: @track_one)
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
        create(:event, conference: subject, track: @track_one)
        create(:event, conference: subject, track: @track_one)
        create(:event, conference: subject, track: @track_two)
        result = {}

        expect(subject.tracks_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for different tracks with confirmed' do
        confirmed_one = create(:event, conference: subject, track: @track_one)
        create(:event, conference: subject, track: @track_one)
        confirmed_two = create(:event, conference: subject, track: @track_two)

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
          'color' => '#ffffff'
        }
        expect(subject.tracks_distribution(:confirmed)).to eq(result)
      end

      it 'calculates correct for one track' do
        confirmed = create(:event, conference: subject, track: @track_one)
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

      expect(Conference.get_conferences_without_active_for_dashboard([subject])).
        to match_array(result)
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
      a = create(:conference, start_date: Time.now - 2.year, end_date: Time.now - 720.days)
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

  describe '#event_distribution' do
    before(:each) do
      @conference = create(
        :conference,
        email_settings: create(:email_settings))
      @conference.email_settings = create(:email_settings)

      @options = {}
      @options[:send_mail] = 'false'

      create(:event, conference: @conference)

      withdrawn = create(:event, conference: @conference)
      withdrawn.withdraw!

      unconfirmed = create(:event, conference: @conference)
      unconfirmed.accept!(@options)

      rejected = create(:event, conference: @conference)
      rejected.reject!(@options)

      confirmed = create(:event, conference: @conference)
      confirmed.accept!(@options)
      confirmed.confirm!

      canceled = create(:event, conference: @conference)
      canceled.accept!(@options)
      canceled.cancel!

      @result = {}
      @result['New'] = { 'value' => 1, 'color' => '#0000FF' }
      @result['Withdrawn'] = { 'value' => 1, 'color' => '#FF8000' }
      @result['Unconfirmed'] = { 'value' => 1, 'color' => '#FFFF00' }
      @result['Rejected'] = { 'value' => 1, 'color' => '#FF0000' }
      @result['Confirmed'] = { 'value' => 1, 'color' => '#00FF00' }
      @result['Canceled'] = { 'value' => 1, 'color' => '#848484' }
    end

    it '#event_distribution does calculate correct values with events' do
      expect(@conference.event_distribution).to eq(@result)
    end

    it '#event_distribution does calculate correct values with no events' do
      @conference.events.clear
      expect(@conference.event_distribution).to eq({})
    end

    it 'event_distribution does calculate correct values with just a new event' do
      conference = create(:conference)
      create(:event, conference: conference)
      result = { 'New' => { 'value' => 1, 'color' => '#0000FF' } }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an withdrawn event' do
      conference = create(:conference)
      event = create(:event, conference: conference)
      event.withdraw!
      result = { 'Withdrawn' => { 'value' => 1, 'color' => '#FF8000' } }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an unconfirmed event' do
      conference = create(:conference)
      event = create(:event, conference: conference)
      event.accept!(@options)
      result = { 'Unconfirmed' => { 'value' => 1, 'color' => '#FFFF00' } }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an rejected event' do
      conference = create(:conference)
      event = create(:event, conference: conference)
      event.reject!(@options)
      result = { 'Rejected' =>  { 'value' => 1, 'color' => '#FF0000' } }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an confirmed event' do
      conference = create(:conference)
      conference.email_settings = create(:email_settings)
      event = create(:event, conference: conference)
      event.accept!(@options)
      event.confirm!
      result = { 'Confirmed' =>  { 'value' => 1, 'color' => '#00FF00' } }
      expect(conference.event_distribution).to eq(result)
    end

    it 'event_distribution does calculate correct values with just an canceled event' do
      conference = create(:conference)
      event = create(:event, conference: conference)
      event.accept!(@options)
      event.cancel!
      result = { 'Canceled' =>  { 'value' => 1, 'color' => '#848484' } }
      expect(conference.event_distribution).to eq(result)
    end

    it 'self#event_distribution does calculate correct values' do
      expect(Conference.event_distribution).to eq(@result)
    end

    it 'self#event_distribution does calculate correct values with no events' do
      @conference.events.clear
      expect(Conference.event_distribution).to eq({})
    end

    it 'self#event_distribution does calculate correct values with just a new event' do
      @conference.events.clear
      create(:event, conference: @conference)
      result = { 'New' => { 'value' => 1, 'color' => '#0000FF' } }
      expect(Conference.event_distribution).to eq(result)
    end

    it 'self#event_distribution does calculate correct values
                      with just a new events from different conferences' do
      create(:event, conference: @conference)
      @result['New'] = { 'value' => 2, 'color' => '#0000FF' }
      expect(Conference.event_distribution).to eq(@result)
    end
  end

  describe 'self#event_distribution' do
    let!(:conference) { create(:conference) }
    let!(:organizer_role) { create(:organizer_role, resource: conference) }
    let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

    it 'self#event_distribution calculates correct values with user' do
      create(:user, last_sign_in_at: Date.today - 3.months) # active
      create(:user, confirmed_at: nil) # unconfirmed
      create(:user, last_sign_in_at: Date.today - 1.year - 1.day) # dead
      result = {}
      result['Active'] = { 'color' => 'green', 'value' => 1 }
      result['Unconfirmed'] = { 'color' => 'red', 'value' => 1 }
      result['Dead'] = { 'color' => 'black', 'value' => 1 }

      expect(Conference.user_distribution).to eq(result)
    end

    it 'self#event_distribution calculates correct with only active user' do
      create(:user, last_sign_in_at: Date.today - 3.months) # active
      result = {}
      result['Active'] = { 'color' => 'green', 'value' => 1 }

      expect(Conference.user_distribution).to eq(result)
    end

    it 'self#event_distribution calculates correct values with only unconfirmed user' do
      create(:user, confirmed_at: nil) # unconfirmed
      result = {}
      result['Unconfirmed'] = { 'color' => 'red', 'value' => 1 }

      expect(Conference.user_distribution).to eq(result)
    end

    it 'self#event_distribution calculates correct values with only dead user' do
      create(:user, last_sign_in_at: Time.now - 1.year - 1.day) # dead
      result = {}
      result['Dead'] = { 'color' => 'black', 'value' => 1 }

      expect(Conference.user_distribution).to eq(result)
    end

    it 'self#event_distribution calculates correct values without user' do
      expect(Conference.user_distribution).to eq({})
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
      @result_false = {}
      @result.each { |key, value| @result_false[key] = !value }

      @result['short_title'] = @result_false['short_title'] = subject.short_title
      @result['process'] = 100.to_s
      @result_false['process'] = 0.to_s
    end

    it 'calculates correct for new conference' do
      subject.call_for_paper = nil
      subject.venue = nil
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.call_for_paper = nil
      subject.venue = nil
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['registration'] = true
      @result_false['process'] = 12.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.call_for_paper = create(:call_for_paper)
      subject.venue = nil
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['process'] = 25.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.call_for_paper = create(:call_for_paper)
      subject.venue = create(:venue)
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['process'] = 37.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue, rooms' do
      subject.rooms = [create(:room)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.call_for_paper = create(:call_for_paper)
      subject.venue = create(:venue)
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []
      subject.splashpage = create(:splashpage, public: false)

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['process'] = 50.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue, rooms, tracks' do
      subject.rooms = [create(:room)]
      subject.tracks = [create(:track)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.call_for_paper = create(:call_for_paper)
      subject.venue = create(:venue)
      subject.event_types = []
      subject.difficulty_levels = []
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
      subject.rooms = [create(:room)]
      subject.tracks = [create(:track)]
      subject.event_types = [create(:event_type)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.call_for_paper = create(:call_for_paper)
      subject.venue = create(:venue)
      subject.difficulty_levels = []
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
      subject.rooms = [create(:room)]
      subject.tracks = [create(:track)]
      subject.event_types = [create(:event_type)]
      subject.difficulty_levels = [create(:difficulty_level)]
      subject.registration_period = create(:registration_period,
                                           start_date: Date.today,
                                           end_date: Date.today + 14)
      subject.venue = create(:venue)
      subject.call_for_paper = create(:call_for_paper)
      subject.venue = create(:venue)
      subject.splashpage = create(:splashpage, public: true)

      expect(subject.get_status).to eq(@result)
    end
  end

  describe '#registration_weeks' do
    it 'calculates new year' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2013, 12, 31),
                                           end_date: Date.new(2013, 12, 30) + 6)
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is one if start and end are 6 days apart' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 6)
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is one if start and end date are the same' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26))
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is two if start and end are 10 days apart' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 10)
      expect(subject.registration_weeks).to eq(2)
    end
  end

  describe '#cfp_weeks' do
    it 'calculates new year' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2013, 12, 30)
      cfp.end_date = Date.new(2013, 12, 30) + 6
      subject.call_for_paper = cfp
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is one if start and end are 6 days apart' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 6
      subject.call_for_paper = cfp
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is one if start and end are the same date' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26)
      subject.call_for_paper = cfp
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is two if start and end are 10 days apart' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 10
      subject.call_for_paper = cfp
      expect(subject.cfp_weeks).to eq(2)
    end
  end

  describe '#get_submissions_per_week' do
    it 'does calculate correct if cfp start date is altered' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) - 7)]
      expect(subject.get_submissions_per_week).to eq([1, 1, 1, 1, 1])
    end

    it 'does calculate correct if cfp end date is altered' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 28)]
      expect(subject.get_submissions_per_week).to eq([0, 0, 0, 0, 1])
    end

    it 'pads with zeros if there are no submissions' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      expect(subject.get_submissions_per_week).to eq([0, 0, 0, 0])
    end

    it 'summarized correct if there are no submissions in one week' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 28
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 28)]
      expect(subject.get_submissions_per_week).to eq([0, 1, 2, 2, 3])
    end

    it 'summarized correct if there are submissions every week except the first' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      expect(subject.get_submissions_per_week).to eq([0, 1, 2, 2])
    end

    it 'summarized correct if there are submissions every week' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      expect(subject.get_submissions_per_week).to eq([1, 2, 3, 3])
    end

    it 'pads left' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 21)]
      expect(subject.get_submissions_per_week).to eq([0, 0, 0, 1])
    end

    it 'pads middle' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 21)]
      expect(subject.get_submissions_per_week).to eq([1, 1, 1, 2])
    end

    it 'pads right' do
      cfp = create(:call_for_paper)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_paper = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      expect(subject.get_submissions_per_week).to eq([1, 1, 1, 1])
    end
  end

  describe '#get_registrations_per_week' do
    it 'pads with zeros if there are no registrations' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 21)

      expect(subject.get_registrations_per_week).to eq([0, 0, 0, 0])
    end

    it 'summarized correct if there are no registrations in one week' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 28)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)

      expect(subject.get_registrations_per_week).to eq([0, 1, 2, 2, 3])
    end

    it 'returns [1] if there is one registration on the first day' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 7)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      expect(subject.get_registrations_per_week).to eq([1, 1])
    end

    it 'summarized correct if there are registrations every week' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 21)

      create(:registration, conference: subject, created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)

      expect(subject.get_registrations_per_week).to eq([1, 2, 3, 3])
    end

    it 'summarized correct if there are registrations every week except the first' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 28)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)

      expect(subject.get_registrations_per_week).to eq([0, 1, 2, 2, 3])
    end

    it 'pads left' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 35)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 21)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 35)

      expect(subject.get_registrations_per_week).to eq([0, 0, 0, 1, 2, 3])
    end

    it 'pads middle' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 35)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 35)

      expect(subject.get_registrations_per_week).to eq([1, 1, 1, 1, 1, 2])
    end

    it 'pads right' do
      subject.registration_period = create(:registration_period,
                                           start_date: Date.new(2014, 05, 26),
                                           end_date: Date.new(2014, 05, 26) + 35)

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)

      expect(subject.get_registrations_per_week).to eq([1, 2, 2, 2, 2, 2])
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
        enrollment = create(:registration_period,
                            start_date: Date.today - 1,
                            end_date: Date.today + 7)
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
        expect(subject.cfp_open?).to be false
      end
    end

    context 'open cfp' do
      before do
        subject.call_for_paper = create(:call_for_paper)
      end

      it '#registration_open? is true' do
        expect(subject.cfp_open?).to be true
      end
    end
  end

  describe '#user_registered?' do
    # It is necessary to use bang version of let to build roles before user
    let!(:conference) { create(:conference) }
    let!(:organizer_role) { create(:organizer_role, resource: conference) }
    let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

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

    it 'is not valid with a duplicate short title' do
      should validate_uniqueness_of(:short_title)
    end

    it 'is valid with a short title that contains a-zA-Z0-9_-' do
      should allow_value('abc_xyz-ABC-XYZ-012_89').for(:short_title)
    end

    it 'is not valid with a short title that contains special characters' do
      should_not allow_value('&%§!?äÄüÜ/()').for(:short_title)
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
end
