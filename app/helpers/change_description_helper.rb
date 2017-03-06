module ChangeDescriptionHelper
  ##
  # Groups functions related to change description
  ##
  def subscription_change_description(version)
    user = current_or_last_object_state(version.item_type, version.item_id).user
    user_name = user.name unless user.id.to_s == version.whodunnit
    version.event == 'create' ? "subscribed #{user_name} to" : "unsubscribed #{user_name} from"
  end

  def registration_change_description(version)
    if version.item_type == 'Registration'
      user = current_or_last_object_state(version.item_type, version.item_id).user
    elsif version.item_type == 'EventsRegistration'
      registration_id = current_or_last_object_state(version.item_type, version.item_id).registration_id
      user = current_or_last_object_state('Registration', registration_id).user
    end

    if user.id.to_s == version.whodunnit
      case version.event
      when 'create' then 'registered to'
      when 'update' then "updated #{updated_attributes(version)} of the registration for"
      when 'destroy' then 'unregistered  from'
      end
    else
      case version.event
      when 'create' then "registered #{user.name} to"
      when 'update' then "updated #{updated_attributes(version)} of  #{user.name}'s registration for"
      when 'destroy' then "unregistered #{user.name} from"
      end
    end
  end

  def comment_change_description(version)
    user = current_or_last_object_state(version.item_type, version.item_id).user
    if version.event == 'create'
      version.previous.nil? ? 'commented on' : "re-added #{user.name}'s comment on"
    else
      "deleted #{user.name}'s comment on"
    end
  end

  def vote_change_description(version)
    user = current_or_last_object_state(version.item_type, version.item_id).user
    if version.event == 'create'
      version.previous.nil? ? 'voted on' : "re-added #{user.name}'s vote on"
    elsif version.event == 'update'
      "updated #{user.name}'s vote on"
    else
      "deleted #{user.name}'s vote on"
    end
  end

  def general_change_description(version)
    if version.event == 'create'
      'created new'
    elsif version.event == 'update'
      "updated #{updated_attributes(version)} of"
    else
      'deleted'
    end
  end

  def event_change_description(version)
    case
    when version.event == 'create' then 'submitted new'

    when version.changeset['state']
      case version.changeset['state'][1]
      when 'unconfirmed' then 'accepted'
      when 'withdrawn' then 'withdrew'
      when 'canceled', 'rejected', 'confirmed' then version.changeset['state'][1]
      when 'new' then 'resubmitted'
      end

    else
      "updated #{updated_attributes(version)} of"
    end
  end

  def event_schedule_change_description(version)
    case version.event
    when 'create' then 'scheduled'
    when 'update' then 'rescheduled'
    when 'destroy' then 'unscheduled'
    end
  end
end
