namespace :db do
  
  desc "Database Drop"
  task :drop => :environment do
    puts "-> Clear Corpus directory : #{File.join(AppConfig.storage_path, Rails.env)}"
    FileUtils.rm_rf File.join(AppConfig.storage_path, Rails.env)
  end
  
  desc "Database Re-Install"
  task :install do	
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['thinking_sphinx:index'].invoke
    #Rake::Task['db:seed'].invoke
  end
end

namespace :ak do
  desc "Swich to production"
  task :production do
    `rm -rf public/assets`
    Rake::Task['assets:precompile'].invoke
  end 
end

namespace :keepalive do
  desc "Keep Alive HTTP"
  task :http do 
=begin
    require 'net/ping'
    include Net
    ph = Net::Ping::HTTP.new(http)
=end
  end
end

namespace :generate do
  desc "Generate Specific Server Configuration"
  task :config, :server_name do |t, args|
    `cd #{Rails.root}/`
    `mkdir config/deploy/templates/#{args[:server_name]}`
    `cp config/antikobpae.default.yml config/deploy/templates/#{args[:server_name]}/antikobpae.yml`
    `cp config/database.default.yml config/deploy/templates/#{args[:server_name]}/database.yml`
    `cp config/ldap.default.yml config/deploy/templates/#{args[:server_name]}/ldap.yml`
    `cp config/sphinx.default.yml config/deploy/templates/#{args[:server_name]}/sphinx.yml`
    `git add config/deploy/templates/#{args[:server_name]}/*`
  end    
end

namespace :sphinx do
  
  desc "Stop the sphinx server"
  task :stop do #, :roles => [:app], :only => {:sphinx => true} do
    Rake::Task['thinking_sphinx:stop'].invoke
  end

  desc "Reindex the sphinx server"
  task :index do #, :roles => [:app], :only => {:sphinx => true} do
    Rake::Task['thinking_sphinx:index'].invoke
  end

  desc "Configure the sphinx server"
  task :configure do #, :roles => [:app], :only => {:sphinx => true} do
    Rake::Task['thinking_sphinx:configure'].invoke
  end

  desc "Start the sphinx server"
  task :start do #, :roles => [:app], :only => {:sphinx => true} do
    Rake::Task['thinking_sphinx:start'].invoke
  end

  desc "Restart the sphinx server"
  task :restart do #, :roles => [:app], :only => {:sphinx => true} do
    Rake::Task['thinking_sphinx:running_start'].invoke
  end
  
  desc "Index deltas to sphinx server"
  task :deltas do
    Rake::Task['thinking_sphinx:delayed_delta'].invoke
  end
 
end