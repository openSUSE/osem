class DomainConstraint
  def self.matches?(request)
  	@domains = Conference.pluck(:custom_domain).compact
    @domains.include?(request.domain)
  end
end