AppConfig = OpenStruct.new(YAML.load_file("#{Rails.root}/config/antikobpae.yml")[Rails.env].symbolize_keys) #if require 'ostruct'

Paperclip.options[:image_magick_path] = AppConfig.image_magick_path
Paperclip.options[:command_path] = AppConfig.image_magick_path

