return unless defined?(RailsDb)

RailsDb.setup do |config|
  # config.http_basic_authentication_enabled = true
  # config.http_basic_authentication_user_name = ENV.fetch("RAILS_DB_USER", "admin")
  # config.http_basic_authentication_password = ENV.fetch("RAILS_DB_PASSWORD", "secret")
  # config.verify_access_proc = ->(controller) { Rails.env.development? }
end
