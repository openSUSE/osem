class Target < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  default_scope { order('due_date ASC') }

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  def self.units
    {
      registrations: 'Registration',
      submissions: 'Submission',
      program_minutes: 'Program minute'
    }
  end

  validates :due_date, :target_count, :unit, presence: true
  validates :target_count,
            allow_nil: false,
            numericality: { only_integer: true, greater_than: 0 }
  validates :unit, allow_nil: false, inclusion: { in: Target.units.values }

  belongs_to :conference
  belongs_to :campaign

  ##
  # Returns the actual progress of the target in percent.
  #
  # ====Returns
  # * +String+ -> progress in percent
  def get_progress
    numerator =
      case unit
      when Target.units[:submissions]
        conference.program.events.where('created_at < ?', due_date).count
      when Target.units[:registrations]
        conference.registrations.where('created_at < ?', due_date).count
      when Target.units[:program_minutes]
        conference.current_program_minutes
      else
        0
      end

    (100 * numerator / target_count).to_s
  end

  ##
  # Returns a hash with values of the corresponding campaign.
  #
  # ====Returns
  # * +Hash+ -> target_name, campaign_name, value, unit, created_at, progress, days_left
  def get_campaign
    numerator = 0
    if unit == Target.units[:submissions]
      numerator = campaign.submissions_count
    elsif unit == Target.units[:registrations]
      numerator = campaign.registrations_count
    elsif unit == Target.units[:program_minutes]
      numerator = conference.current_program_minutes
    end

    progress = (numerator / target_count.to_f * 100).round(0).to_s
    result = {
      'target_name' => to_s,
      'campaign_name' => campaign.name,
      'value' => numerator,
      'unit' => unit,
      'created_at' => created_at,
      'progress' => progress,
      'days_left' => days_left
    }
    result
  end

  def to_s
    "#{pluralize(target_count, unit)} by #{due_date}"
  end

  private

  def days_left
    (due_date - Date.today).to_i
  end
end
