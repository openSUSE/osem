# frozen_string_literal: true

# == Schema Information
#
# Table name: schedules
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  program_id :integer
#  track_id   :integer
#
# Indexes
#
#  index_schedules_on_program_id  (program_id)
#  index_schedules_on_track_id    (track_id)
#
require 'spec_helper'

describe Schedule do

  describe 'association' do
    it { should belong_to(:program) }
    it { should belong_to(:track) }
    it { should have_many(:event_schedules).dependent(:destroy) }
    it { should have_many(:events).through(:event_schedules) }
  end
end
