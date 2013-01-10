Delayed::Worker.backend = :active_record

Resque.after_fork do |job|
  ActiveRecord::Base.connection.reconnect!
end