include ActionView::Helpers::TextHelper

class ScanFile < ActiveRecord::Base
  serialize :time

  belongs_to :scan
  belongs_to :document
  has_many :duplicate_ranges, :through => :similarities, :foreign_key => "scan_file_duplicate_range"
  has_many :similarities, :dependent => :destroy
  
  attr_accessible :document, :status, :progress, :score, :time
  
  def start_scan
    require "benchmark"
  
    update_attributes(:status => 1, :progress => 0, :time => Benchmark::Tms.new)
    
    time = Benchmark.measure do
      self.search
      #sphinx_exit = Process.wait(fork_with_new_connection { self.search }) if scan.sphinx
      #web_exit = Process.wait(fork_with_new_connection { self.web_search }) if scan.web
    end
    
    update_attributes(:status => 2, :progress => 100, :time => time)
  end
  
  handle_asynchronously :start_scan, :queue => 'scans'
  
  def search(limit=50)
    tolerence = scan.tolerence
    words = Marshal.load(File.open([document.attachment.path,'words','obj'].join('.')))
    matches = Hash.new
    rebuilt = false
    size = words.length-tolerence
    
    # 1. Document Filtering 
    puts "<ScanFile ##{id}> Sphinx Search..."
    begin
      i = 0
      while(i < size)
      #for i in (0..size) 
        #self.update_attributes(:progress => 75*i/size)
        hash = words[i..i+tolerence]*' '
        i+=tolerence
        contents = Content.search hash, :match_mode => :phrase
        contents.each do |content|
          src_id = content.document_id
          matches[src_id]=0 if matches[src_id].nil?
          matches[src_id]+=1
        end
      end
    rescue Riddle::ConnectionError => e
      puts "=> Riddle::ConnectionError: #{e}. Rebuilding Sphinx..."
      Rake::Task['thinking_sphinx:rebuild'].invoke
      rebuilt ? raise : rebuilt = true and retry
    rescue Errno::EADDRNOTAVAIL => e
      puts "Errno::EADDRNOTAVAIL => #{e.message}"  
    #rescue => e
    #  puts "OTHER::ERROR => #{e.inspect}"
    end
    
    puts "<ScanFile ##{id}> #{matches.length} Sphinx Results"
    return if matches.empty?
    
    # 2. Matches Sorting
    matches = matches.sort {|a,b| b[1] <=> a[1]}
    matches.select! {|src_id, score| src = Document.find(src_id)
      #skip = src == document # Identical
      #skip ||= (src.from == 'web') # Web Cache
      #skip ||= (src.from == 'scan' && src.folder != scan.folder)
      #!skip
      true
    }
    
    # 3. Hightlighting
    limit = matches.length if matches.length < limit
    Parallel.each_with_index(matches.take(limit), :in_processes => 10) do |hash, i| 
      ActiveRecord::Base.connection.reconnect!
      src_id, score = hash[0], hash[1]
      source = Document.find(src_id)
      self.update_attributes(:progress => 75+25*i/limit)
      puts "<ScanFile ##{id}> <=> <Document ##{source.id}>"
      compare_with source
    end     
    
    self.update_attributes(:progress => 100)
  end
  
  def compare_with(source)
    
    return if source.id == document.id
    similarities.by_document(source).destroy_all    
    tolerence = scan.tolerence
    doc_words = Marshal.load(File.open([document.attachment.path,'words','obj'].join('.')))
    src_words = Marshal.load(File.open([source.attachment.path,'words','obj'].join('.')))
    doc_ranges = Marshal.load(File.open([document.attachment.path,'ranges','obj'].join('.')))
    src_ranges = Marshal.load(File.open([source.attachment.path,'ranges','obj'].join('.')))
    doc_max, src_max = doc_words.length, src_words.length
    
    print "  | Filtering Text..."    
    commons = doc_words & src_words
    dup_filter = Parallel.map([doc_words, src_words]) do |m|
      m.collect
        .with_index { |w, i| i if commons.include? w }
        .chunk{|v| v.nil? }
        .reject{|sep,ans| sep}
        .map{|sep,ans| ans}
        .select { |a| a.length >= tolerence }   
    end
    doc_matches, src_matches = dup_filter[0], dup_filter[1]
    puts " Done."  
    
    puts "  | Finding Similarities... "
    sims = Parallel.map(doc_matches, :in_threads => 3) do |doc_match|
      Parallel.map(src_matches, :in_threads => 3) do |src_match|       
        doc_chunk = doc_words[doc_match.first..doc_match.last]
        src_chunk = src_words[src_match.first..src_match.last]
        results = DiffLCS.diff(doc_chunk, src_chunk, :minimum_lcs_size => tolerence)
        [results[:matched_old], results[:matched_new]].transpose.map do |r|
          doc_start, doc_end = doc_match.first+r[0].first, doc_match.first+r[0].last-1
          src_start, src_end = src_match.first+r[1].first, src_match.first+r[1].last-1
          puts "  |=> Similarity - #{doc_end - doc_start} words: [#{doc_start}..#{doc_end}]/#{doc_max} <=> [#{src_start}..#{src_end}]/#{src_max}"
          { 
            :doc => { :from_word => doc_start, :to_word => doc_end, :from_char => doc_ranges[doc_start][:start], :to_char => doc_ranges[doc_end][:end] },
            :src => { :from_word => src_start, :to_word => src_end, :from_char => src_ranges[src_start][:start], :to_char => src_ranges[src_end][:end] }
          }
        end
	    end
    end
    sims.flatten.each do |sim|       
      doc_dup, src_dup = DuplicateRange.create(sim[:doc]), DuplicateRange.create(sim[:src])
      similarities.create(:document => source, :is_exception => false, :is_validated => false, :scan_file_duplicate_range => doc_dup, :document_duplicate_range => src_dup)
    end
    puts '  | Done.'
    
    print '  | Updating Score... '
    calculate_score
    puts ' Done.'
  end
  
  def calculate_score
    self.dup_words = 0
    self.dup_chars = 0
    word_ranges = similarities.map { |sim| (sim.scan_file_duplicate_range.from_word..sim.scan_file_duplicate_range.to_word) } 
    char_ranges = similarities.map { |sim| (sim.scan_file_duplicate_range.from_char..sim.scan_file_duplicate_range.to_char) }
    merge_ranges(word_ranges).each { |range| self.dup_words += range.to_a.size }
    merge_ranges(char_ranges).each { |range| self.dup_chars += range.to_a.size }
    self.word_score = self.dup_words.to_f*100.0/(document.words_length.to_f-1)
    self.char_score = self.dup_chars.to_f*100.0/(document.chars_length.to_f-1)
    self.score = (self.word_score + self.char_score) / 2.0
    save!
  end
  
  def merge_ranges(ranges)
    ranges = ranges.sort_by {|r| r.first }
    *outages = ranges.shift
    ranges.each do |r|
      lastr = outages[-1]
      if lastr.last >= r.first - 1
        outages[-1] = lastr.first..[r.last, lastr.last].max
      else
        outages.push(r)
      end
    end
    outages
  end
  
  def count_sources
    similarities.collect {|s| s.document.id}.uniq.length
  end
  
  def count_file_sources
    similarities.collect {|s| s.document.id if s.document.from == 'file' && s.document.folder.id != scan.folder.id}.compact.uniq.length
  end
  
  def count_web_sources
    similarities.collect {|s| s.document.id if s.document.from == 'web'}.compact.uniq.length
  end
  
  def count_recursive_sources
    similarities.collect {|s| s.document.id if s.document.folder.id == scan.folder.id}.compact.uniq.length
  end
  
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
    
    def marshal(string)
      [Marshal.dump(string)].pack('m*')
    end

    def unmarshal(str)
      Marshal.load(str.unpack("m")[0])
    end
end
