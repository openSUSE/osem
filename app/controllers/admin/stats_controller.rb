class Admin::StatsController < ApplicationController
  before_filter :verify_organizer
  
  def index
    @registrations = @conference.registrations.all(:joins => :person,
                                                   :order => "registrations.created_at ASC",
                                                   :select => "registrations.*,
                                                               people.last_name AS last_name,
                                                               people.first_name AS first_name,
                                                               people.public_name AS public_name,
                                                               people.email AS email")

    @pre_registered = @conference.registrations.where("onsite = ?", false).count

    @registered_attended = @conference.registrations.where("attended = ? AND onsite = ?", true, false).count
    @registered_onsite = @conference.registrations.where("onsite LIKE ?", true).count
    @registered_not_attended = @conference.registrations.where("attended LIKE ? AND onsite LIKE ?", false, false).count

    @attendees = @conference.registrations.where("attended = ?", true).count

    @registered_with_partner = @conference.registrations.where("attending_with_partner = ?", true).count
    @attended_with_partner = @conference.registrations.where("attending_with_partner = ? AND attended = ?", true, true).count

    @headers = %w[attended name email social_events with_partner need_access other_needs arrival departure onsite]
    
    @events = @conference.events
    @tracks = @conference.tracks
    @event_states = @events.state_machine.states.map
    @speakers = Person.joins(:events).where("events.conference_id = ? AND events.state LIKE ?", @conference.id,  'confirmed').uniq
    @speaker_fields_person = %w[name email affiliation]
    @speaker_fields_reg = %w[with_partner need_access other_needs diet arrival departure]
    
    @supporter_levels = @conference.supporter_levels
    
    @supporter_tickets = "t"
    @professional_tickets = "t"
    
  end
  
  def reg_support (level)
    Registration.find_by_sql("select supporter_registrations.* FROM registrations, supporter_registrations, supporter_levels WHERE registrations.id = supporter_registrations.registration_id AND registrations.conference_id = #{@conference.id} AND supporter_registrations.supporter_level_id = #{level.id}")
    
    
  end
  
  def speaker_reg(speaker)
    speaker.registrations.where("conference_id = ? AND person_id = ?", @conference.id, speaker.id).first
  end
  
  def speaker_diet(reg)
    @conference.dietary_choices.find(reg.dietary_choice_id)
  end
  
  helper_method :speaker_reg
  helper_method :speaker_diet
  helper_method :reg_support
  
end
