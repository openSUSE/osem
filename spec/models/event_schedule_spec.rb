require 'spec_helper'

describe EventSchedule do

  describe 'association' do
    it { should belong_to(:schedule) }
    it { should belong_to(:event) }
    it { should belong_to(:room) }
  end
end
