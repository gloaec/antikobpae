# run with: god -c /path/to/file.god -D
RAILS_ROOT = "<%= latest_release %>"
RAILS_ENV = "<%= rails_env %>"
USER = "<%= user %>"
GROUP = "<%= group %>"
RUBY_PATH = "<%= rvm_bin_path %>"
APACHE_BIN = "<%= [:redhat, :rhel, :fedora, :centos].include?(distribution) ? 'httpd' : 'apache2' %>"

# Settings for email notifications (optional)
God::Contacts::Email.defaults do |d|
  d.from_email = 'god@antikobpae.cpe.ku.ac.th'
  d.from_name = 'God KU'
  d.delivery_method = :smtp # this can also be :sendmail
  d.server_host = 'smtp.antikobpae.cpe.ku.ac.th'
  d.server_port = 25
  d.server_auth = true
  d.server_domain = 'antikobpae.cpe.ku.ac.th'
  d.server_user = 'passenger@antikobpae.cpe.ku.ac.th'
  d.server_password = 'kobpae'
end

# People to contact in case of issue
God.contact(:email) do |c|
  c.name = 'ghis'
  c.to_email = 'ghis182@gmail.com'
end

God.watch do |w| # ------------------------------------ Watch for mysql
  w.name = "mysql"
  w.interval = 30.seconds
  w.env = { 
    'RAILS_ROOT' => RAILS_ROOT,
    'RAILS_ENV' => RAILS_ENV,
    'PATH' => "#{RUBY_PATH}:/usr/bin:/bin",
    'PIDFILE' => File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid") 
  }
  w.start = "/etc/init.d/mysqld start && /etc/init.d/#{APACHE_BIN} restart"
  w.stop = "/etc/init.d/mysqld stop"
  w.restart = "/etc/init.d/mysqld restart && /etc/init.d/#{APACHE_BIN} restart"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "/var/run/mysqld/mysqld.pid"
 
  w.behavior(:clean_pid_file)
 
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end
 
  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
    # failsafe
    on.condition(:tries) do |c|
      c.times = 8
      c.within = 2.minutes
      c.transition = :start
    end
  end
 
  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits) do |c|
      c.notify = 'ghis'
    end
  end
 
  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 1.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

God.watch do |w| # ------------------------------------ Watch for delayed_job

  w.name = "delayed_job"
  w.interval = 30.seconds # default
  w.dir = RAILS_ROOT
  w.env = { 
    'RAILS_ROOT' => RAILS_ROOT,
    'RAILS_ENV' => RAILS_ENV,
    'PATH' => "#{RUBY_PATH}:/usr/bin:/bin",
    'PIDFILE' => File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid") 
  }
  w.uid = USER
  w.gid = GROUP
  w.start = File.join(RAILS_ROOT, "script/delayed_job -n 4 --queues=scans,documents,delta start")
  w.restart = "#{File.join(RAILS_ROOT, "script/delayed_job stop")} && #{File.join(RAILS_ROOT, "script/delayed_job -n 4 --queues=scans,documents,delta start")}"#File.join(RAILS_ROOT, "script/delayed_job restart")
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid")
  w.log = File.join(RAILS_ROOT, "log/#{w.name}.log")

  w.behavior(:clean_pid_file)

  w.start_if do |start| 
    start.condition(:process_running) do |c| 
      c.interval = 5.seconds 
      c.running = false 
    end 
    start.condition(:process_exits) do |c|
      c.notify = 'ghis'
    end
  end 

  w.restart_if do |restart| 
    restart.condition(:memory_usage) do |c| 
      c.above = 300.megabytes 
      c.times = [3, 5] # 3 out of 5 intervals 
    end 

    restart.condition(:cpu_usage) do |c| 
      c.above = 50.percent 
      c.times = 5 
    end 
  end 

  # lifecycle 
  w.lifecycle do |on| 
    on.condition(:flapping) do |c| 
      c.to_state = [:start, :restart] 
      c.times = 5 
      c.within = 5.minute 
      c.transition = :unmonitored 
      c.retry_in = 10.minutes 
      c.retry_times = 5 
      c.retry_within = 2.hours 
    end 
  end 
end


God.watch do |w| # ------------------------------------ Watch for apache

  watch_name = "apache"
  w.name = watch_name
  w.interval = 30.seconds # default
  w.dir = RAILS_ROOT
  w.env = { 
    'RAILS_ROOT' => RAILS_ROOT,
    'RAILS_ENV' => RAILS_ENV,
    'PATH' => "#{RUBY_PATH}:/usr/bin:/bin",
    'PIDFILE' => File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid") 
  }
  #w.uid = USER
  #w.gid = GROUP
  w.start = "/etc/init.d/#{APACHE_BIN} start"
  w.stop = "/etc/init.d/#{APACHE_BIN} stop"
  w.restart = "/etc/init.d/#{APACHE_BIN} restart"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  #w.pid_file = File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid")
  w.log = File.join(RAILS_ROOT, "log/#{w.name}.log")
  
  w.start_if do |on|
    on.condition(:http_response_code) do |c|
      c.host = 'localhost'
      c.port = 3000
      c.path = '/'
      c.code_is_not = 200
      c.timeout = 10.seconds
      c.times = [2, 5]
    end
  end
end



God.watch do |w| # ------------------------------------ Watch for sphinx

  watch_name = "sphinx"
  w.name = watch_name
  w.interval = 30.seconds # default
  w.dir = RAILS_ROOT
  w.env = { 
    'RAILS_ROOT' => RAILS_ROOT,
    'RAILS_ENV' => RAILS_ENV,
    'PATH' => "#{RUBY_PATH}:/usr/bin:/bin",
    'PIDFILE' => File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid") 
  }
  #w.uid = USER
  #w.gid = GROUP
  w.start         = "searchd --config #{RAILS_ROOT}/config/#{RAILS_ENV}.sphinx.conf"
  w.stop          = "searchd --config #{RAILS_ROOT}/config/#{RAILS_ENV}.sphinx.conf --stop"
  w.restart       = w.stop + " && " + w.start
  w.start_grace   = 10.seconds
  w.stop_grace    = 10.seconds
  w.restart_grace = 15.seconds
  w.pid_file = File.join(RAILS_ROOT, "tmp/pids/#{w.name}.pid")
  w.log = File.join(RAILS_ROOT, "log/#{w.name}.log")
  
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval  = 5.seconds
      c.running   = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state      = [:start, :restart]
      c.times         = 5
      c.within        = 5.minutes
      c.transition    = :unmonitored
      c.retry_in      = 10.minutes
      c.transition    = :unmonitored
      c.retry_in      = 10.minutes
      c.retry_times   = 5
      c.retry_within  = 2.hours
    end
  end
end
