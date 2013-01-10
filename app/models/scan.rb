class Scan < ActiveRecord::Base

	belongs_to :folder, :dependent => :destroy
	has_many :scan_files, :dependent => :destroy
	has_many :documents, :through => :folder

	attr_accessible :web, :recursive, :scan_files
	
	def start
	  cache_folder = folder.children.find_by_name('Cache') || folder.children.create(:name => 'Cache')
	  cache_folder.documents.destroy_all
	  pids = []
	  Parallel.each(scan_files, :in_processes => 0) do |scan_file|
	    ActiveRecord::Base.connection.reconnect!
	    scan_file.start_scan
	    #pids << fork_with_new_connection { scan_file.start_scan }
    end 
    #Process.waitall()
  end
  
  #handle_asynchronously :start, :queue => 'scans'
  
  def fork_with_new_connection
      config = ActiveRecord::Base.remove_connection
      pid = fork do
        success = true
        begin
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Base.connection.reconnect!
          yield
        rescue Exception => exception
          puts ("Forked operation failed with exception: " + exception)
          success = false
        ensure
          ActiveRecord::Base.remove_connection
          Process.exit! success
        end
      end
      ActiveRecord::Base.establish_connection(config)
      pid
    end
end
