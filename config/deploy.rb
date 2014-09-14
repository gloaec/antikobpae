# RVM bootstrap
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano'
require 'bundler/capistrano'
require 'capistrano_colors'
require './lib/thinking-sphinx/lib/thinking_sphinx/capistrano'
load 'deploy/assets'

set :rvm_type, :system
set :rvm_ruby_string, '1.9.3-p392'
set :rvm_path, "/usr/local/rvm"
set :rvm_gem_path, "#{rvm_path}/gems/ruby-#{rvm_ruby_string}"

# main details
set :server, "antikobpae.cpe.ku.ac.th"
set :port, 9999
set :application, "antikobpae"
role :web, "antikobpae.cpe.ku.ac.th"
role :app, "antikobpae.cpe.ku.ac.th"
role :db,  "antikobpae.cpe.ku.ac.th", :primary => true

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/home/passenger/antikobpae"
set :deploy_via, :remote_cache
set :user, "passenger"
set :group, "passenger"
set :use_sudo, false
set :distribution, :linux # :redhat / :rhel / :fedora / :centos / :debian / :ubuntu / :linux

# repo details
set :scm, :git
set :scm_username, "passenger"
set :repository, "git@github.com:gloaec/antikobpae.git"
set :branch, "master"
set :git_enable_submodules, 1

#after 'deploy:setup', 'deploy:config'
#after 'deploy:finalize_update', 'thinking_sphinx:symlink_indexes'
#after 'deploy:update_code', 'deploy:config_symlink'

before 'deploy:update_code', 'thinking_sphinx:stop'
before 'deploy:assets:precompile', 'deploy:config'
before 'deploy:assets:precompile', 'deploy:config_symlink'
after 'deploy:config_symlink', 'thinking_sphinx:start'
after 'thinking_sphinx:start', 'thinking_sphinx:symlink_indexes'

namespace :thinking_sphinx do
  desc "Symlink Sphinx indexes"
  task :symlink_indexes, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
end

task :god do 
  god.terminate
  god.deploy_config
  god.init
  god.load_config
  god.status
end 

namespace :god do

  ["terminate", "start", "stop", "restart", "status"].each do |cmd|
    task cmd.to_sym, :roles => :app do
      #sudo "service god #{cmd}"
      run "god #{cmd}"
    end
  end
  
  task :init, :roles => :app do 
    run "god -c /etc/god/monitoring.god"
  end

  task :log, :roles => :app do
   sudo "tail -f /var/log/messages"
  end

  task :deploy_config, :roles => :app do
    god_config_file = "#{latest_release}/config/monitoring.god"
    god_script_template = File.dirname(__FILE__) + "/deploy/monitoring.god.erb.rb"
    data = ERB.new(IO.read(god_script_template)).result(binding)
    put data, god_config_file
    sudo "mkdir -p /etc/god", :pty => true
    sudo "ln -sf #{god_config_file} /etc/god/monitoring.god", :pty => true
  end
  
  task :deploy_init_script, :roles => :app do
    god_init_template = File.dirname(__FILE__) + "/deploy/god.init.template.sh"
    data = ERB.new(IO.read(god_init_template)).result(binding)
    put(data, "/tmp/god_init_script", :via => :scp, :mode => "755") # put command doesn't support sudo, so we can't directly copy to /etc/init.d folder
    sudo "mv /tmp/god_init_script /etc/init.d/god"
    sudo "/sbin/chkconfig --add god"
    sudo "/sbin/chkconfig --level 35 god on" # enable run levels 3 and 5
  end
  
  task :load_config, :roles => :app do 
    god_config_file = "#{latest_release}/config/monitoring.god"
    run "god load #{god_config_file}"
  end

  task :deploy, :roles => :app do
    #god.stop
    god.deploy_init_script
    god.deploy_config
    god.start
    god.status
    #god.load_config
  end
end

# tasks
namespace :deploy do
  
  namespace :assets do
    
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision) rescue nil
      if from.nil? || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
    
  end
  
  task :config, :roles => :app do
    server = "antikobpae.cpe.ku.ac.th"
    run [
          "cp #{release_path}/config/deploy/templates/#{server}/antikobpae.yml #{shared_path}/config/antikobpae.yml",
          "cp #{release_path}/config/deploy/templates/#{server}/database.yml #{shared_path}/config/database.yml",
          "cp #{release_path}/config/deploy/templates/#{server}/sphinx.yml #{shared_path}/config/sphinx.yml",
          "cp #{release_path}/config/deploy/templates/#{server}/ldap.yml #{shared_path  }/config/ldap.yml"
    ].join(" && ")
  end
  
  task :config_symlink, :roles => :app do
    run [ "ln -nfs #{shared_path}/config/antikobpae.yml #{release_path}/config/antikobpae.yml",
          "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml",
          "ln -nfs #{shared_path}/config/sphinx.yml #{release_path}/config/sphinx.yml",
          "ln -nfs #{shared_path}/config/ldap.yml #{release_path}/config/ldap.yml",
          "ln -fs #{shared_path}/uploads #{release_path}/uploads"
    ].join(" && ")
  end
    
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
