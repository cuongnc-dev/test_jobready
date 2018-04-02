require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestJobready
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set locale
    config.i18n.default_locale = :vi
    config.i18n.available_locales = [:vi, :en]
    config.i18n.fallbacks = {en: [:vi], vi: [:en]}
    config.middleware.use I18n::JS::Middleware
  end
end
