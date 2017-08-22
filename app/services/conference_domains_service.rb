require 'resolv'

class ConferenceDomainsService
  def initialize(conference, resolver = Resolv::DNS.new)
    @conference = conference
    @resolver = resolver
  end

  ##
  # Checks if domain correctly points to the hosted version
  # This feature is enabled only if ENV['OSEM_HOSTNAME'] is present
  #
  # ====Returns
  # * +true+ -> If the custom domain has a CNAME record for the hosted version
  # * +false+ -> If the custom domain does not have a CNAME record for the hosted version
  def check_custom_domain
    cname_record = @resolver.getresources(@conference.custom_domain, Resolv::DNS::Resource::IN::CNAME)
    cname_record.present? ? ENV['OSEM_HOSTNAME'] == cname_record.name.to_s : false
  end
end
