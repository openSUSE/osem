# frozen_string_literal: true

# == Schema Information
#
# Table name: events_registrations
#
#  id              :bigint           not null, primary key
#  attended        :boolean          default(FALSE), not null
#  created_at      :datetime
#  event_id        :integer
#  registration_id :integer
#
class EventsRegistration < ApplicationRecord
  belongs_to :registration
  belongs_to :event

  has_one :user, through: :registration

  has_paper_trail meta: { conference_id: :conference_id }

  delegate :name, to: :registration
  delegate :email, to: :registration

  validates :event, :registration, presence: true
  validates :event, uniqueness: { scope: :registration }

  private

  def conference_id
    registration.conference_id
  end
end
