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
class Schedule < ApplicationRecord
  belongs_to :program
  belongs_to :track
  has_many :event_schedules, dependent: :destroy
  has_many :events, through: :event_schedules

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  private

  def conference_id
    program.conference_id
  end
end
