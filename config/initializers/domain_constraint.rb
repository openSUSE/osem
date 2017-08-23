class DomainConstraint
  def self.matches?(request)
    domains = Conference.where.not(custom_domain: nil).pluck(:custom_domain)
    domains.include?(request.domain)
  end
end
