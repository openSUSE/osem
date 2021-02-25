# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_periods
#
#  id            :bigint           not null, primary key
#  end_date      :date
#  start_date    :date
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
class RegistrationPeriod < ApplicationRecord
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :start_date, :end_date, presence: true
  validate :before_end_of_conference
  validate :start_date_before_end_date

  private

  def before_end_of_conference
    errors
    .add(:start_date, "can't be after the conference end date (#{conference.end_date})") if conference&.end_date && start_date && (start_date > conference.end_date)

    errors
    .add(:end_date, "can't be after the conference end date (#{conference.end_date})") if conference&.end_date && end_date && (end_date > conference.end_date)
  end

  def start_date_before_end_date
    errors
    .add(:start_date, "can't be after the end date") if start_date && end_date && start_date > end_date
  end
end
