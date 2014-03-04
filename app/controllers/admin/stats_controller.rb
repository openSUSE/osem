class Admin::StatsController < ApplicationController
  before_filter :verify_organizer
  
  def index
    @registrations = @conference.registrations.includes(:person).order("registrations.created_at ASC")

    @attendees = @conference.registrations.where("attended = ?", true).count
    @registered = @conference.registrations.count
    @pre_registered = @conference.registrations.where("created_at < ?", @conference.start_date).count
    @pre_registered_attended = @conference.registrations.where("created_at < ? AND attended = ?", @conference.start_date, true).count

    @registered_with_partner = @conference.registrations.where("attending_with_partner = ?", true).count
    @attended_with_partner = @conference.registrations.where("attending_with_partner = ? AND attended = ?", true, true).count

    @handicapped_access = @conference.registrations.where(handicapped_access_required: true).count
    @handicapped_access_attended = @conference.registrations.where(handicapped_access_required: true)
    @handicapped_access_attended = @handicapped_access_attended.where(attended: true).count
    @suggested_hotel_stay = @conference.registrations.where("using_affiliated_lodging = ?", true).count

    @speakers = Person.joins(:events).where("events.conference_id = ? AND events.state LIKE ?", @conference.id,  'confirmed').uniq
    @speaker_fields_person = %w[name email affiliation]
    @speaker_fields_reg = %w[other_needs diet arrival departure]
    
    @supporter_levels = @conference.supporter_levels
    @tickets = @conference.registrations.joins(:supporter_registration => :supporter_level)
    @tickets = @tickets.where("supporter_levels.title NOT LIKE ? ", "%Free%")

    @mydays = []
    @mytickets = []

    if @conference.registration_start_date and @conference.end_date
      (@conference.registration_start_date..@conference.end_date).each do |day|
        day_reg_count = @registrations.where("created_at LIKE '%#{day}%' ").count
        day_ticket_count = @tickets.where("supporter_registrations.created_at LIKE '%#{day}%' ").count
        if  day_reg_count != 0
          @mydays << {"status" => "#{day}", "value" => day_reg_count}
        end
        @conference.supporter_levels.each do |level|
          day_ticket_count = @tickets.where("supporter_registrations.created_at LIKE ? AND supporter_levels.title LIKE ?", "%#{day}%", "%#{level.title}%").count
          if day_ticket_count !=0
            @mytickets << {"status" => "#{day}", "ticket" => "#{level}", "value" => day_ticket_count}
          end
        end
      end
    end
    
    @other_info = [
      {"status" => "with partner (registered)", "value" => @registered_with_partner}, 
      {"status" => "with partner (attended)", "value" => @attended_with_partner}, 
      {"status" => "handicapped (registered)", "value" => @handicapped_access}, 
      {"status" => "handicapped (attended)", "value" => @handicapped_access_attended}, 
      {"status" => "stay at suggested hotel", "value" => @suggested_hotel_stay}
    ]

  end

  def speaker_reg(speaker)
    speaker.registrations.where("conference_id = ? AND person_id = ?", @conference.id, speaker.id).first
  end

  def speaker_diet(reg)
    @conference.dietary_choices.find(reg.dietary_choice_id)
  end

  def diet_count(diet)
    @conference.registrations.where("dietary_choice_id = ?", diet)
  end

  def social_event_count(event)
    @conference.registrations.joins(:social_events).where("registrations_social_events.social_event_id = ?", event).count
  end

  helper_method :speaker_reg
  helper_method :speaker_diet
  helper_method :diet_count
  helper_method :social_event_count
end
