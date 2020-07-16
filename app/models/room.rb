# frozen_string_literal: true

class Room < ApplicationRecord
  include RevisionCount
  belongs_to :venue
  has_many :event_schedules, dependent: :destroy
  has_many :tracks

  has_paper_trail ignore: [:guid], meta: { conference_id: :conference_id }

  before_create :generate_guid

  validates :name, :venue_id, presence: true

  validates :size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :order, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  default_scope { order(order: :asc) }

  def conference
    venue.conference
  end

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
    self.guid = guid
  end

  def conference_id
    venue.conference_id
  end
end
