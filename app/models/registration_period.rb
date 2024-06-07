# frozen_string_literal: true

class RegistrationPeriod < ApplicationRecord
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :start_date, :end_date, presence: true
  validate :start_before_end_of_conference
  validate :end_before_end_of_conference
  validate :start_date_before_end_date

  private

  def start_before_end_of_conference
    return unless conference
    return unless start_date

    errors
    .add(:start_date, "can't start after the conference end date (#{conference.end_date})") if start_date > conference.end_date
  end

  def end_before_end_of_conference
    return unless conference
    return unless end_date

    errors
    .add(:end_date, "can't end after the conference end date (#{conference.end_date})") if end_date > conference.end_date
  end

  def start_date_before_end_date
    return unless start_date && end_date

    errors
    .add(:start_date, "can't be after the end date") if start_date > end_date
  end
end
