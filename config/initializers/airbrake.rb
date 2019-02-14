Airbrake.configure do |config|
  # Change this to some sensible data for your errbit instance
  config.project_id = ENV['OSEM_ERRBIT_ID'] || Rails.application.secrets.errbit_id || ''
  config.project_key = ENV['OSEM_ERRBIT_KEY'] || Rails.application.secrets.errbit_key || ''
  config.host    = ENV['OSEM_ERRBIT_HOST']
  config.environment = Rails.env
  if config.project_key.blank? || config.host.blank?
    config.ignore_environments = [:production, :development, :test]
  else
    config.ignore_environments = [:development, :test]
  end
end

Airbrake.add_filter do |notice|
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'ActiveRecord::RecordNotFound' }
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'ActionController::InvalidAuthenticityToken' }
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'ActionController::UnknownAction' }
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'AbstractController::ActionNotFound' }
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'ActionView::MissingTemplate' }
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'ActionController::UnknownFormat' }
  notice.ignore! if notice[:errors].any? { |error| error[:type] == 'ActionController::RoutingError' && error[:message] =~ %r{\[GET\]} }
end
