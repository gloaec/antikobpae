class Scan < ActiveRecord::Base

	belongs_to :folder, :dependent => :destroy
	has_many :scan_files, :dependent => :destroy
	has_many :documents, :through => :folder

	attr_accessible :web, :recursive, :scan_files
	
	def start
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

    def progress
      if self.scan_files.size == 0
        0
      else
        self.scan_files.map(&:progress).reduce(:+).to_f / self.scan_files.size
      end
    end

    def count_documents
      self.documents.count
    end

    def count_pending
      self.scan_files.where(progress: 0).count || self.documents.count
    end

    def count_passed
      self.scan_files.where(progress: 100, score: 0).count
    end

    def count_suspicious
      self.scan_files.where(progress: 100, score: 1..50).count
    end

    def count_plagiarized
      self.scan_files.where(progress: 100, score: 51..100).count
    end

    def count_similarities
      self.scan_files.map {|sf| sf.similarities.count }.reduce(:+) || 0
    end

    def count_sources
      self.scan_files.map {|sf|
        sf.similarities.collect {|s| s.document.id}
      }.flatten.uniq.length
    end
end
