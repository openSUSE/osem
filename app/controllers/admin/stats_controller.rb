class Admin::StatsController < ApplicationController
  before_filter :verify_organizer
  
  def index
    @registrations = @conference.registrations.includes(:person).order("registrations.created_at ASC")

    @attendees = @conference.registrations.where("attended = ?", true).count
    @registered = @conference.registrations.count

    @registered_with_partner = @conference.registrations.where("attending_with_partner = ?", true).count
    @attended_with_partner = @conference.registrations.where("attending_with_partner = ? AND attended = ?", true, true).count

    @speakers = Person.joins(:events).where("events.conference_id = ? AND events.state LIKE ?", @conference.id,  'confirmed').uniq
    @speaker_fields_person = %w[name email affiliation]
    @speaker_fields_reg = %w[with_partner need_access other_needs diet arrival departure]
    
    @supporter_levels = @conference.supporter_levels
    @tickets = @conference.registrations.joins(:supporter_registration => :supporter_level)
    @tickets = @tickets.where("registrations.conference_id" => @conference).count
  end
  
  def speaker_reg(speaker)
    speaker.registrations.where("conference_id = ? AND person_id = ?", @conference.id, speaker.id).first
  end
  
  def speaker_diet(reg)
    @conference.dietary_choices.find(reg.dietary_choice_id)
  end
  
  helper_method :speaker_reg
  helper_method :speaker_diet
end
