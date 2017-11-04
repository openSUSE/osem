require 'feature'

repo = Feature::Repository::SimpleRepository.new

# configure features here
unless(ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?)
  repo.add_active_feature :recaptcha
end

Feature.set_repository repo
