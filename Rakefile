# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'thinking_sphinx/deltas/delayed_delta/tasks'
require 'rake'
# Comment this for deployement, it executes twice throwing errors
# require 'thinking_sphinx/tasks'


AntiKobpae::Application.load_tasks
