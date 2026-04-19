Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.traces_sample_rate = 0.0
  config.profiles_sample_rate = 0.0
  config.enabled_environments = %w[production staging]
  config.environment = Rails.env
  config.release = ENV["KAMAL_VERSION"]
end
