module UsersHelper
  ##
  # Includes functions related to users
  ##
  # Set devise_mapping for devise so that we can call the devise help links (views/devise/shared/_links) from anywhere (eg sign_up form in proposals#new)
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def omniauth_configured
    providers = []
    Devise.omniauth_providers.each do |provider|
      provider_key = "#{provider}_key"
      provider_secret = "#{provider}_secret"
      unless Rails.application.secrets.send(provider_key).blank? || Rails.application.secrets.send(provider_secret).blank?
        providers << provider
      end
      providers << provider if !ENV["OSEM_#{provider.upcase}_KEY"].blank? && !ENV["OSEM_#{provider.upcase}_SECRET"].blank?
    end

    return providers.uniq
  end

  # Receives a hash, generated from User model, function get_roles
  # Outputs the roles of a user, including the conferences for which the user has the roles
  # Eg. organizer(oSC13, oSC14), cfp(oSC12, oSC13)
  def show_roles(roles)
    roles.map{ |x| x[0].titleize + ' (' + x[1].join(', ') + ')' }.join ', '
  end

  def can_manage_volunteers(conference)
    if (current_user.has_role? :organizer, conference) || (current_user.has_role? :volunteers_coordinator, conference)
      true
    else
      false
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
