# frozen_string_literal: true

module VersionsHelper
  ##
  # Groups functions related to change description
  ##
  def link_if_alive(version, link_text, link_url, conference)
    version.item && conference ? link_to(link_text, link_url) : "#{link_text} with ID #{version.item_id}"
  end

  def link_to_organization(organization_id)
    return 'deleted organization' unless organization_id

    org = Organization.find_by(id: organization_id)
    return current_or_last_object_state('Organization', organization_id).try(:name) unless org

    org.name.to_s
  end

  def link_to_conference(conference_id)
    return 'deleted conference' if conference_id.nil?

    conference = Conference.find_by(id: conference_id)
    if conference
      link_to conference.short_title,
              edit_admin_conference_path(conference.short_title)
    else
      short_title = current_or_last_object_state('Conference', conference_id).try(:short_title) || ''
      " #{short_title} with ID #{conference_id}"
    end
  end

  def link_to_user(user_id)
    return 'Someone (probably via the console)' unless user_id

    user = User.find_by(id: user_id)
    if user
      link_to user.name, admin_user_path(id: user_id)
    else
      name = current_or_last_object_state('User', user_id).try(:name) || PaperTrail::Version.where(item_type: 'User', item_id: user_id).last.changeset['name'].second if PaperTrail::Version.where(item_type: 'User', item_id: user_id).any?
      "#{name ? name : 'Unknown user'} with ID #{user_id}"
    end
  end

  # Receives a model_name and id
  # Returns nil if model_name is invalid
  # Returns object in its current state if its alive
  # Otherwise Returns object state just before deletion
  def current_or_last_object_state(model_name, id)
    return nil unless id.present? && model_name.present?

    begin
      object = model_name.constantize.find_by(id: id)
    rescue NameError
      return nil
    end

    if object.nil?
      object_last_version = PaperTrail::Version.where(item_type: model_name, item_id: id).last
      object = object_last_version.reify if object_last_version
    end
    object
  end

  def subscription_change_description(version)
    user_id = current_or_last_object_state(version.item_type, version.item_id).user_id
    user_name = User.find_by(id: user_id).try(:name) || current_or_last_object_state('User', user_id).try(:name) || PaperTrail::Version.where(item_type: 'User', item_id: user_id).last.changeset[:name].second unless user_id.to_s == version.whodunnit
    version.event == 'create' ? "subscribed #{user_name} to" : "unsubscribed #{user_name} from"
  end

  def registration_change_description(version)
    if version.item_type == 'Registration'
      user_id = current_or_last_object_state(version.item_type, version.item_id)&.user_id
    elsif version.item_type == 'EventsRegistration'
      registration_id = current_or_last_object_state(version.item_type, version.item_id).registration_id
      user_id = current_or_last_object_state('Registration', registration_id).user_id
    end
    user_name = User.find_by(id: user_id).try(:name) || current_or_last_object_state('User', user_id).try(:name) || (PaperTrail::Version.where(item_type: 'User', item_id: user_id).last&.changeset || {})[:name]&.second

    if user_id.to_s == version.whodunnit
      case version.event
      when 'create' then 'registered to'
      when 'update' then "updated #{updated_attributes(version)} of the registration for"
      when 'destroy' then 'unregistered from'
      end
    else
      case version.event
      when 'create' then "registered #{user_name} to"
      when 'update' then "updated #{updated_attributes(version)} of  #{user_name}'s registration for"
      when 'destroy' then "unregistered #{user_name} from"
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

  def user_change_description(version)
    if version.event == 'create'
      link_to_user(version.item_id) + ' signed up'
    elsif version.event == 'update'
      if version.changeset.keys.include?('reset_password_sent_at')
        'Someone requested password reset of'
      elsif version.changeset.keys.include?('confirmed_at') && version.changeset['confirmed_at'][0].nil?
        (version.whodunnit.nil? ? link_to_user(version.item_id) : link_to_user(version.whodunnit)) + ' confirmed account of'
      elsif version.changeset.keys.include?('confirmed_at') && version.changeset['confirmed_at'][1].nil?
        link_to_user(version.whodunnit) + ' unconfirmed account of'
      else
        link_to_user(version.whodunnit) + " updated #{updated_attributes(version)} of"
      end
    end
  end

  def users_role_change_description(version)
    version.event == 'create' ? 'added' : 'removed'
  end
end
