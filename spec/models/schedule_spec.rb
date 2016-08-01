require 'spec_helper'

describe Schedule do

  describe 'association' do
    it { should belong_to(:program) }
    it { should have_many(:event_schedules).dependent(:destroy) }
    it { should have_many(:events).through(:event_schedules) }
  end
end
