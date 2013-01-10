
# Load the rails application
require File.expand_path('../application', __FILE__)

#Mime::Type.register 'application/pdf', :pdf
Mime::Type.register 'application/original', :orig

# Initialize the rails application
AntiKobpae::Application.initialize!

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8


#config.gem(
##  'thinking-sphinx', :version => '1.4.4'
#)