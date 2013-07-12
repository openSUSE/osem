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

    @attendees = @conference.registrations.where("attended = ?", true).count
    @registered = @conference.registrations.count

    @registered_with_partner = @conference.registrations.where("attending_with_partner = ?", true).count
    @attended_with_partner = @conference.registrations.where("attending_with_partner = ? AND attended = ?", true, true).count

    @speakers = Person.joins(:events).where("events.conference_id = ? AND events.state LIKE ?", @conference.id,  'confirmed').uniq
    @speaker_fields_person = %w[name email affiliation]
    @speaker_fields_reg = %w[with_partner need_access other_needs diet arrival departure]
    
    @supporter_levels = @conference.supporter_levels
  end
  
  def reg_support(level)
    Registration.find_by_sql("select supporter_registrations.* 
    FROM registrations INNER JOIN supporter_registrations
    ON registrations.id = supporter_registrations.registration_id
    WHERE registrations.conference_id = #{@conference.id} 
    AND supporter_registrations.supporter_level_id = #{level.id}")
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
