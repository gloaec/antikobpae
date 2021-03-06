require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module AntiKobpae
  class Application < Rails::Application
    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]
       
    # CK Editor utils
    config.autoload_paths += %W(#{config.root}/app/models/ckeditor)
    
    %w(observers mailers middleware).each do |dir|
      config.autoload_paths << "#{config.root}/app/#{dir}"
    end
    
    config.assets.paths << Rails.root.join("app", "assets", "flashs")
    config.assets.paths << File.join(Rails.root,'public','javascripts') 
    
    config.jquery_templates.prefix = "templates"

   config.action_mailer.delivery_method = :smtp
   config.action_mailer.smtp_settings = {
     :domain => "gmail.com",
     :address => 'smtp.gmail.com',
     :port => 587,
     :user_name => 'ghis182@gmail.com',
     :password => 'gl824272',
     :authentication => 'plain'
   }
  config.action_controller.asset_host = 'http://localhost:3000'
  config.action_mailer.asset_host = config.action_controller.asset_host
  config.action_mailer.default_url_options = { host: config.action_controller.asset_host }
  routes.default_url_options = { host: config.action_controller.asset_host }
    

    config.yml = OpenStruct.new(YAML.load_file("#{Rails.root}/config/antikobpae.yml")[::Rails.env].symbolize_keys) #OpenStruct.new(YAML.load_file("#{Rails.root}/config/antikobpae.yml")[Rails.env].symbolize_keys) if require 'ostruct'
  end
end
