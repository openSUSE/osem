require 'spec_helper'

describe Cfp do
  subject { create(:cfp) }
  let!(:conference) { create(:conference, end_date: Date.today) }
  let!(:cfp) { create(:cfp, start_date: Date.today - 2, end_date: Date.today - 1, program_id: conference.program.id) }

  describe 'scope' do
    describe '#for_events' do
      it 'returns the cfp for events' do
        expect(conference.program.cfps.for_events).to be_a Cfp
        expect(conference.program.cfps.for_events.cfp_type).to eq('events')
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:cfp_type) }
    it { is_expected.to validate_inclusion_of(:cfp_type).in_array(Cfp::TYPES) }
    it { is_expected.to validate_uniqueness_of(:cfp_type).scoped_to(:program_id).case_insensitive }
  end

  describe '#before_end_of_conference' do
    describe 'fails to save cfp' do
      it 'when cfp end_date is after conference end_date' do
        cfp.end_date = Date.today + 1
        expect(cfp.valid?).to be false
      end

      it 'when cfp start_date is after conference end_date' do
        cfp.start_date = Date.today + 1
        expect(cfp.valid?).to be false
      end
    end

    describe 'successfully saves cfp' do
      it 'when cfp end_date and start_date are before the conference end_date' do
        expect(cfp.valid?).to be true
      end
    end
  end

  describe '#start_after_end_date' do
    it 'succeeds when cfp start_date is after cfp end_date' do
      expect(cfp.valid?).to be true
    end

    it 'fails when cfp start_date is after cfp end_date' do
      cfp.start_date = Date.today
      expect(cfp.valid?).to be false
    end
  end

  describe '#notify_on_cfp_date_update?' do
    before :each do
      email_settings = conference.email_settings
      email_settings.send_on_cfp_dates_updated = true
      email_settings.cfp_dates_updated_subject = 'subject'
      email_settings.cfp_dates_updated_body = 'body text'
      email_settings.save!

      cfp.save!
    end

    describe 'returns true' do
      it 'when end_date changed' do
        cfp.end_date = Date.today
        expect(cfp.start_date_changed?).to eq false
        expect(cfp.end_date_changed?).to eq true
        expect(cfp.notify_on_cfp_date_update?).to eq true
      end

      it 'when start_date changed' do
        cfp.start_date = Date.today
        expect(cfp.end_date_changed?).to eq false
        expect(cfp.start_date_changed?).to eq true
        expect(cfp.notify_on_cfp_date_update?).to eq true
      end
    end

    describe 'returns false' do
      it 'when there is no change in cfp dates' do
        expect(cfp.start_date_changed?).to eq false
        expect(cfp.end_date_changed?).to eq false
        expect(cfp.notify_on_cfp_date_update?).to eq false
      end

      it 'when send_on_cfp_dates_updates is not set' do
        conference.email_settings.send_on_cfp_dates_updated = false
        conference.email_settings.save!
        cfp.end_date = Date.today

        expect(cfp.end_date_changed?).to eq true
        expect(cfp.notify_on_cfp_date_update?).to eq false
      end

      it 'when cfp_dates_updates_subject is not set' do
        conference.email_settings.cfp_dates_updated_subject = ''
        conference.email_settings.save!
        cfp.end_date = Date.today

        expect(cfp.end_date_changed?).to eq true
        expect(cfp.notify_on_cfp_date_update?).to eq false
      end

      it 'when cfp_dates_updates_template is not set' do
        conference.email_settings.cfp_dates_updated_body = ''
        conference.email_settings.save!
        cfp.end_date = Date.today

        expect(cfp.end_date_changed?).to eq true
        expect(cfp.notify_on_cfp_date_update?).to eq false
      end
    end
  end

  describe '#open?' do
    context 'returns false' do
      it 'when start and end dates are in the past' do
        cfp.start_date = Date.current - 3
        cfp.end_date = Date.current - 1
        expect(cfp.open?).to eq(false)
      end

      it 'when start and end dates are in the future' do
        cfp.start_date = Date.current + 1
        cfp.end_date = Date.current + 3
        expect(cfp.open?).to eq(false)
      end
    end

    context 'returns true' do
      it 'when start date is in the past and end date is in the future' do
        cfp.start_date = Date.current - 1
        cfp.end_date = Date.current + 1
        expect(cfp.open?).to eq(true)
      end
    end
  end
end
