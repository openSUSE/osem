class ConferenceDomainsService
  def initialize(params)
    @conference = params[:conference]
  end

  ##
  # Checks if domain correctly points to the hosted version
  # This feature is enabled only if ENV['OSEM_HOSTNAME'] is present
  #
  # ====Returns
  # * +true+ -> If the custom domain has a CNAME record for the hosted version
  # * +false+ -> If the custom domain does not have a CNAME record for the hosted version
  def check_custom_domain
    require 'resolv'

    unless ENV['OSEM_HOSTNAME'].nil?
      cname_record = Resolv::DNS.new.getresources(@conference.custom_domain, Resolv::DNS::Resource::IN::CNAME)
      if cname_record.present?
        return ENV['OSEM_HOSTNAME'] == Resolv::DNS.new.getresources(custom_domain, Resolv::DNS::Resource::IN::CNAME).first.name.to_s
      else
        return false
      end
    end

    '--feature disabled--'
  end
end
