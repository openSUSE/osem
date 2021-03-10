# frozen_string_literal: true

# == Schema Information
#
# Table name: cfps
#
#  id                   :bigint           not null, primary key
#  cfp_type             :string
#  description          :text
#  enable_registrations :boolean          default(FALSE)
#  end_date             :date             not null
#  start_date           :date             not null
#  created_at           :datetime
#  updated_at           :datetime
#  program_id           :integer
#

class Cfp < ApplicationRecord
  TYPES = %w(events booths tracks).freeze

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }
  belongs_to :program

  validates :program_id, presence: true
  validates :start_date, :end_date, presence: true
  validate :before_end_of_conference
  validate :start_after_end_date
  validates :cfp_type,
            presence:   true,
            inclusion:  {
              in: TYPES
            },
            uniqueness: {
              scope:          :program_id,
              case_sensitive: false
            }

  ##
  # Checks whether cfp date is updated
  #
  # ====Returns
  # * +True+ -> If cfp dates is updated and all other parameters are set
  # * +False+ -> Either cfp date is not updated or one or more parameter is not set
  def notify_on_cfp_date_update?
    !end_date.blank? && !start_date.blank?\
    && (start_date_changed? || end_date_changed?)\
    && program.conference.email_settings.send_on_cfp_dates_updated\
    && !program.conference.email_settings.cfp_dates_updated_subject.blank?\
    && !program.conference.email_settings.cfp_dates_updated_body.blank?
  end

  ##
  # Calculates how many weeks the call for paper is.
  #
  # ====Returns
  # * +Integer+ -> start week
  def weeks
    result = end_week - start_week + 1
    weeks = Date.new(start_date.year, 12, 31).strftime('%W').to_i
    result < 0 ? result + weeks : result
  end

  ##
  # Calculates the end week of the cfp
  #
  # ====Returns
  def start_week
    start_date.strftime('%W').to_i
  end

  ##
  # Calculates the end week of the cfp
  #
  # ====Returns
  def end_week
    end_date.strftime('%W').to_i
  end

  def remaining_days(date = Date.today)
    result = (end_date - date).to_i
    result > 0 ? result : 0
  end

  ##
  # Checks if the call for papers is currently open
  #
  # ====Returns
  # * +false+ -> If the CFP is not set or today isn't in the CFP period.
  # * +true+ -> If today is in the CFP period.
  def open?
    (start_date..end_date).cover?(Date.current)
  end

  ##
  # Finds the cfp for events if it exists
  #
  # ====Returns
  # * +Cfp+ -> The cfp with type 'events'
  def self.for_events
    find_by(cfp_type: 'events')
  end

  ##
  # Finds the cfp for tracks if it exists
  #
  # ====Returns
  # * +Cfp+ -> The cfp with type 'tracks'
  def self.for_tracks
    find_by(cfp_type: 'tracks')
  end

  ##
  # Finds the cfp for booths if it exists
  #
  # ====Returns
  # * +Cfp+ -> The cfp with type 'booths'
  def self.for_booths
    find_by(cfp_type: 'booths')
  end

  private

  def before_end_of_conference
    if program&.conference&.end_date && end_date && (end_date > program.conference.end_date)
      errors.add(
        :end_date,
        "can't be after the conference end date (#{program.conference.end_date})"
      )
    end

    if program&.conference&.end_date && start_date && (start_date > program.conference.end_date)
      errors.add(
        :start_date,
        "can't be after the conference end date (#{program.conference.end_date})"
      )
    end
  end

  def start_after_end_date
    errors
    .add(:start_date, "can't be after the end date") if start_date && end_date && start_date > end_date
  end

  def conference_id
    program.conference_id
  end
end
