require 'spec_helper'

describe Target do

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:target)).to be_valid
    end

    it 'is not valid without a due date' do
      should validate_presence_of(:due_date)
    end

    it 'is not valid without a target_count' do
      should validate_presence_of(:target_count)
    end

    it 'is not valid without a unit' do
      should validate_presence_of(:unit)
    end

    it 'is valid with a target_count greater than zero' do
      should allow_value(10).for(:target_count)
    end

    it 'is not valid with a target_count equals zero' do
      should_not allow_value(0).for(:target_count)
    end

    it 'is not valid with a target_count smaller than zero' do
      should_not allow_value(-10).for(:target_count)
    end
  end

  describe '#get_progress' do
    it 'returns zero if there are no registrations' do
      conference = build(:conference)
      target = build(:target, target_count: 10, unit: Target.units[:registrations])
      conference.targets = [target]

      expect(target.get_progress).to eq('0')
    end

    it 'returns 10 if there one registrations of 10' do
      conference = create(:conference)
      target = create(:target, target_count: 10, unit: Target.units[:registrations])
      registration = create(:registration)

      conference.targets = [target]
      conference.registrations = [registration]

      expect(target.get_progress).to eq('10')
    end

    it 'returns zero if there are no submissions' do
      conference = build(:conference)
      target = build(:target, target_count: 10, unit: Target.units[:submissions])
      conference.targets = [target]

      expect(target.get_progress).to eq('0')
    end

    it 'returns 10 if there one submissions of 10' do
      conference = create(:conference)
      target = create(:target, target_count: 10, unit: Target.units[:submissions])
      event = create(:event)

      conference.targets = [target]
      conference.events = [event]

      expect(target.get_progress).to eq('10')
    end

    it 'returns zero if there are no program minutes' do
      conference = build(:conference)
      target = build(:target, target_count: 10, unit: Target.units[:program_minutes])
      conference.targets = [target]

      expect(target.get_progress).to eq('0')
    end

    it 'returns 10 if there are 30 program minutes of 300' do
      conference = create(:conference)
      target = create(:target, target_count: 300, unit: Target.units[:program_minutes])
      event = create(:event)

      conference.targets = [target]
      conference.events = [event]

      expect(target.get_progress).to eq('10')
    end
  end

  describe '#to_s' do
    it 'returns a string in the correct format' do
      conference = build(:conference)
      target = build(:target, target_count: 10, unit: Target.units[:registrations])
      conference.targets = [target]

      result = "10 Registrations by #{14.days.from_now.to_date}"

      expect(target.to_s).to eq(result)
    end
  end
end
