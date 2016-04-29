HoptoadNotifier.configure do |config|
  # Change this to some sensible data for your errbit instance
  config.api_key = ENV['OSEM_ERRBIT_APIKEY'] || Rails.application.secrets.errbit_key || ''
  config.host    = ENV['OSEM_ERRBIT_HOST']
  if config.api_key.blank? || config.host.blank?
    config.development_environments = 'production development test'
  else
    config.development_environments = 'development test'
  end

  config.ignore_only = %w{
    ActiveRecord::RecordNotFound
    ActionController::InvalidAuthenticityToken
    ActionController::UnknownAction
    AbstractController::ActionNotFound
    ActionView::MissingTemplate
    ActionController::UnknownFormat
  }

  config.ignore_by_filter do |exception_data|
    ret=false
    if exception_data[:error_class] == 'ActionController::RoutingError'
      message = exception_data[:error_message]
      ret=true if message =~ %r{\[GET\]}
    end
    ret
  end

end
