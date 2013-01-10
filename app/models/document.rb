# encoding: utf-8

#require 'pdftohtmlr'
#require 'doctohtmlr'
require 'ruby-rtf'
#require 'iconv'
require 'nokogiri'
require 'tempfile'
require 'fileutils'
require 'thinking_sphinx'
#require 'tokyocabinet'
#require 'pdf-reader'

#include PDF
#include PDFToHTMLR
#include DOCToHTMLR
#include RubyRTF
#include TokyoCabinet
include ActionView::Helpers::TextHelper

class EncodeError < RuntimeError; end
class SegmentationError < RuntimeError; end
class ConversionError < RuntimeError; end

class Document < ActiveRecord::Base
  has_attached_file :attachment, :path => "#{AppConfig.storage_path}/:rails_env/:id/:style/content"
  belongs_to :folder
  belongs_to :user
  has_one :scan_file, :dependent => :destroy
  has_many :share_links, :dependent => :destroy
  has_many :duplicate_ranges, :through => :similarities, :foreign_key => "document_duplicate_range"
  has_many :similarities, :dependent => :destroy
  has_many :images
  has_many :metadatas
  
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :metadatas
  #attr_accessible :user
 
  validate :check_file
  validates_attachment_presence :attachment, :message => I18n.t(:blank, :scope => [:activerecord, :errors, :messages])
  validates_presence_of [:folder_id, :name]
  validates_format_of :name, :with => /^[^\/\\\?\*:|"<>]+$/, :message => I18n.t(:invalid_characters, :scope => [:activerecord, :errors, :messages])
  validates_format_of :attachment_file_type, :with => %r{^(file|docx|doc|pdf|odt|txt|html|rtf)$}i, :message => I18n.t(:file_format_not_supported)
  validates_uniqueness_of :name, :scope => 'folder_id', :message => I18n.t(:exists_already, :scope => [:activerecord, :errors, :messages])

  after_save :check_for_existing_file
  
  #handle_asynchronously :process_document
  #after_commit :set_file_delta_flag
  #after_update :check_for_indexing 
  
  define_index do
    indexes attachment_file_name, :sortable => true
    indexes content
    set_property :delta => :delayed
    #has created_at, updated_at
  end
  
  def copy(target_folder)
    new_file = self.dup
    new_file.instance_eval { @errors = nil }
    new_file.folder = target_folder
    new_file.save!

    path = "#{AppConfig.storage_path}/#{Rails.env}/#{new_file.id}"
    FileUtils.mkdir_p path
    FileUtils.cp_r File.dirname(self.attachment.path), path

    new_file
  end
 
  def move(target_folder)
    self.folder = target_folder
    save!
  end
  
  def extension
    self.attachment_file_type
  end

  def process_document
    puts "<Document ##{id}> Processing Document..."
    generate_html
    generate_txt
    generate_cut
    generate_db
    generate_index
  end
  
  def destroy
    scan_files = Similarity.by_document(self).map { |s| s.scan_file }.uniq
    FileUtils.rm_rf File.dirname(self.attachment.path)
    FileUtils.rm_rf "#{Rails.root}/uploads/#{Rails.env}/#{id}" if Dir["#{Rails.root}/uploads/#{Rails.env}/#{id}/*"].empty?
    super
    scan_files.each {|sf| sf.calculate_score }
  end

  private 
  
  def check_file
    #self.attachment_file_name = self.name unless self.name.nil?
    self.attachment_file_type = self.attachment_file_type || File.extname(attachment_file_name)[1..-1] unless self.attachment_file_name.nil? 
  end
  
  def check_for_existing_file
  	if status < 1
  	  unless File.exists?(attachment.path)
	      FileUtils.mkdir_p File.dirname(attachment.path)
	      FileUtils.touch attachment.path
      end
      File.open([attachment.path,'html'].join('.'), 'w:UTF-8') do |f|
        unless content.nil?
          f.puts content
        else
  	      f.puts "<div class='option info'><h3>Converting...</h3><p>Please wait, your document is being converted.</p></div>"
  	    end
  	  end
  	  self.attachment_file_size = File.size([attachment.path,'html'].join('.')) if attachment_file_type == 'file'
	    self.status = content.nil? ? 1 : 2
	    self.content = nil
	    save!
	    if self.from == 'web'
        process_document
      elsif self.from == 'scan'
        self.delay(:queue => 'scans').process_document
      else
        self.delay(:queue => 'documents').process_document
      end
    end
  end
  
  def generate_utf8(encoding=nil)  
       
    #FileUtils.mv attachment.path, [attachment.path,attachment_file_type].join('.')

=begin
    cmd = [
      [Rails.root,'bin','thaiconv'].join('/'),
      '-r', [attachment.path].join('.'),
      '-out',1,'>',[attachment.path, attachment_file_type].join('.')
    ].join(' ')
    
    puts "<Document ##{id}> Converting to UTF-8 : #{cmd}"
    output = `#{cmd} 2>&1`
   puts "=> #{output}"
=end
        
    if encoding.nil?
      cmd = [AppConfig.chardet_bin, attachment.path].join(' ')
      
      print "<Document ##{id}> Detecting Encoding..." 
      output = `#{cmd} 2>&1`    
    
      if output.include?('No such file or directory')
        raise EncodeError, [output,'=> `chardet` binaries not found'].join("\n")
      end
    
      data = /^[^:]+:\s?([^\s]+)\s?\(\s?confidence:\s?([^\)]+\s?)/.match(output)
    
      raise EncodeError, [output,'=> `chardet` Problem'].join("\n") if data.nil?
      encoding, confidence = ["ISO-8859-2"].include?(data[1]) ? "TIS-620" : data[1], data[2]
      encoding.upcase!
      puts " => #{encoding}"
    end
    
    unless encoding == "UTF-8"
      #temp_file = Tempfile.new('ak', :encoding => 'UTF-8')	
      
      cmd = [
      [Rails.root,'bin','thaiconv'].join('/'),
      '-r', attachment.path,
      '-out',1,'>',[attachment.path, attachment_file_type].join('.')
    ].join(' ')

    puts "<Document ##{id}> Converting #{encoding} to UTF-8 : #{cmd}"
    output = `#{cmd} 2>&1`
    #puts "=> #{output}"
=begin
      begin       
        cmd = [
          AppConfig.iconv_bin,
          '-f', encoding,
          '-t', 'UTF-8',
          '-o', temp_file.path,
          [attachment.path, attachment_file_type].join('.')
        ].join(' ')

        puts "<Document ##{id}> Converting #{encoding} to UTF-8 : #{cmd}"

        output = `#{cmd} 2>&1`

        if output.include?('illegal input sequence')
          puts "<Document ##{id}> EncodeError: #{output}"
          raise EncodeError
        elsif output.include?('No such file or directory')
          raise EncodeError, [output,'=> `iconv` binaries not found'].join("\n")
        end

      rescue EncodeError
        encoding = encoding == 'TIS-620' ? "ISO-8859-11" : "UTF-8"
        puts "<Document ##{id}> Attempting to convert from #{encoding} encoding"
        retry
      end

      FileUtils.mv temp_file.path, [attachment.path, attachment_file_type].join('.')
      temp_file.close
=end
    else
      FileUtils.mv attachment.path, [attachment.path,attachment_file_type].join('.')
    end
  end
	
  def generate_html
	  
	  case attachment_file_type
    when 'txt'
      generate_utf8
	    FileUtils.cp [attachment.path,attachment_file_type].join('.'), [attachment.path,'html'].join('.')
	  when 'file'
	    return
	  when 'html'  
	    
	    unless self.from == 'web'
	    
	      self.status = 2
  	    save!
	    
  	    require 'open-uri'
        require 'net/http'
        require 'net/https'
        retry_exceptions = [Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNRESET]
        ignore_exceptions = [OpenURI::HTTPError, SocketError]
        
        uri = ''
        begin
  	      uri = URI.parse(URI.escape(self.attachment_file_name)) 
        rescue URI::InvalidURIError
          require 'cgi'
          uri = URI.parse(CGI.escape(self.attachment_file_name))
        end
        
  	    retries = 3
  	    response = nil
  	    encoding = nil
	    
  	    # NOTE : Convert if PDF || DOC
  	    puts "<Document ##{id}> Retrieving contents from: #{self.attachment_file_name}"
	    
  	    begin
  	      #Timeout::timeout(60){
  	        file = open(uri)
  	        File.open(attachment.path, "wb") do |f|
  	          f.write file.read
            end
  	        #FileUtils.mv file.path, attachment.path
  	      #}
  	      
=begin
          Timeout::timeout(20){
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true if uri.scheme == 'https'
            response = http.start { |session| session.get uri.request_uri }
          }
          response.type_params.each_pair do |k,v|
            encoding = v.upcase if k =~ /charset/i
          end

          unless encoding
            encoding = response.body =~ /<meta[^>]*HTTP-EQUIV=["']Content-Type["'][^>]*content=["'](.*)["']/i && $1 =~ /charset=(.+)/i && $1.upcase
          end

          File.open(attachment.path, "wb") do |f|
            f.write response.body
          end
=end
        rescue *retry_exceptions => e
          retries -= 1
          puts "=> ERROR: #{e.message} - #{retries} retries left"
          if retries > 0
            sleep 0.42 and retry
          else
            puts "=> ERROR: #{e.message}"
            File.open(attachment.path, "wb") do |f|
              f.write "<div class='option error'><h1>WebPage Timeout</h1>"
              f.write "<p>The server couldn't retrieve this webpage content because is was getting too long..</p></div>"
            end
  	        return
          end
        rescue *ignore_exceptions => e
  	      puts "=> ERROR: #{e.message}"
          File.open(attachment.path, "wb") do |f|
            f.write "<div class='option error'><h1>WebPage Timeout</h1>"
            f.write "<p>The server couldn't retrieve this webpage content because is was getting too long..</p></div>"
          end
  	      return
  	    end
      end
      
      file_type = File.extname(self.attachment_file_name)[1..-1]
      
      if !file_type.nil? && ['doc','docx','pdf'].include?(file_type.downcase)
        self.name = title = File.basename(self.attachment_file_name, File.extname(self.attachment_file_name)) || self.name
        count = 1
        until self.folder.documents.find_by_name(self.name).nil? 
          self.name = "#{title} (#{count})"
          count += 1
        end
        self.attachment_file_type = file_type
        return generate_html
      else
        generate_utf8
      end
=begin     
      doc = if encoding 
        begin
          puts "DOC ##{id} => #{encoding}"
          #utf8_body = response.body.ensure_encoding('UTF-8', :external_encoding => 'ISO-8859-1', :invalid_characters => :transcode)
          #puts utf8_body
          Nokogiri::HTML(open(uri)) #response.body.force_encoding(encoding).encode('utf-8')
        rescue Encoding::UndefinedConversionError 
          encoding = encoding == 'TIS-620' ? "ISO-8859-11" : encoding == 'UTF-8' ? "TIS-620" : 'UTF-8'
          retry unless encoding == "ISO-8859-11"
          Nokogiri::HTML(response.body)
        end
      else
        Nokogiri::HTML(File.open([attachment.path,'html'].join('.'), "w:UTF-8"))
      end
=end      
      
      doc = Nokogiri::HTML(File.open([attachment.path,'html'].join('.'),'r:UTF-8').read, nil, 'UTF-8')
      
      self.name = title = doc.css('title').inner_text.gsub(/[\/\\\?\*:|"<>]+/, ' ') unless doc.css('title').blank?
      
      count = 1
      until self.folder.documents.find_by_name(self.name).nil? 
        self.name = "#{title} (#{count})"
        count += 1
      end
      
      doc.search('head','script','style','link').remove
      doc.xpath('//@style').each(&:remove)
      doc.xpath('//@class').each(&:remove)
      doc.xpath('//@id').each(&:remove)
      doc.xpath("//meta").each do |tag|
        document.metadatas.create(:key => tag.attributes['name'], :value => tag.attributes['content'])
      end
      
	    File.open([attachment.path,'html'].join('.'), 'wb') do |f|
	      f.puts doc.css('body').inner_html
      end
	  else
	    return if File.exists?([attachment.path,attachment_file_type].join('.')) #self.status > 1
	    self.status = 2
	    save!
	    
	    FileUtils.mv attachment.path, [attachment.path,attachment_file_type].join('.') #unless File.exists?([attachment.path,attachment_file_type].join('.'))
	    
	    if self.text_only
	      generate_html_from attachment_file_type
      else   
	      cmd = [
    	  	AppConfig.soffice_bin, 
    	  	'--convert-to', 'html','"'+[attachment.path,attachment_file_type].join('.')+'"',
    	  	'--outdir', File.dirname(attachment.path),
    	  	'--nologo','--nofirststartwizard','--headless',
    	  	'--norestore','--nodefault','--invisible'
    	  ].join(' ')
	  
    	  puts "<Document ##{id}> Generating HTML: $ #{cmd}"
    	  output = `#{cmd} 2>&1`
        puts "=> #{output}"

        html_content = File.open([attachment.path,'html'].join('.')).read

        if output.downcase.include?('error') || html_content.include?("<div class='option info'>")
      	    self.text_only = true
      	  	generate_html_from attachment_file_type
      	else
          doc = Nokogiri::HTML(html_content)
      
    	    File.open([attachment.path,'html'].join('.'), 'w:UTF-8') do |f|
    	      FileUtils.mkdir_p [File.dirname(attachment.path),'images'].join('/')
            image_id = 1 
    	  	  f.puts '<style>'+doc.css('style').inner_text.gsub(/(cm)/, "em")+'</style>'
    	  	  move_images = ""
    	  	  doc.xpath("//p").each do |p|
    	  	    img = p.children.first
    	  	    if img.name == 'img' 
    	  	      height = /height:\s?(\d+\.?\d*)cm/.match(img.attr('style'))[1].to_f*30
      	        width = /width:\s?(\d+\.?\d*)cm/.match(img.attr('style'))[1].to_f*30
      	        header = /data:\s?image\/([\w\*]+);b?a?s?e?6?4?,?/.match(img.attr('src'))
      	        type = !header[1].nil? ? header[1] == '*' ? 'png' : header[1] : 'png'
                if width < 100 || height < 100
                  move_images += p.inner_html
                  next
                end
    	  	      puts "Extract Image => #{header[0]}"
      	  	    File.open([File.dirname(attachment.path),'images',"#{image_id}.#{type}"].join('/'),'wb') do |f_img|
      	  	      f_img.write Base64.decode64(img['src'].sub(header[0],''))
      	  	    end
      	  	    new_image = self.images.create(:attachment => File.new([File.dirname(attachment.path),'images',"#{image_id}.#{type}"].join('/')))
    	  	      image_id += 1
  	            move_images += "<a class=\"fancybox\" href=\"#{new_image.attachment.url(:large)}\"><img src=\"#{new_image.attachment.url(:thumb)}\" /></a>"
  	  	      else
      	  	    f.puts p.inner_html
      	  	    f.puts '<br/>'
      	  	    f.puts move_images
      	  	    move_images = ""
    	        end
    	  	  end
  	  	  end
  	    end 
  	  end 	  
	  end
	  
    self.attachment_file_size = File.size([attachment.path,'html'].join('.'))
    save!
  end
  
  def generate_html_from(format)
    
    case format
    when 'doc', 'docx'
      
      cmd = [
        AppConfig.abiword_bin,
        [attachment.path,attachment_file_type].join('.'),
        '-t','html',
        '-o', [attachment.path,'html'].join('.')
      ].join(' ')
      
      puts "<Document ##{id}> Generating TEXT-ONLY for #{format} (Abiword): #{cmd}"
  	  output = `#{cmd} 2>&1`
      puts "=> #{output}"
      
    when 'pdf'
      puts "<Document ##{id}> Generating TEXT-ONLY for #{format} (PDF::Reader)"
      begin      
        reader = PDF::Reader.new([attachment.path,attachment_file_type].join('.'))
      
        File.open([attachment.path,'html'].join('.'), 'w:UTF-8') do |f|
          reader.pages.each do |page|
            #f.puts page.fonts
            f.puts page.text
            #f.puts page.raw_content
            #f.puts '-------'
          end
        end
      rescue *[PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError]
        self.status = -1
        save!
      end
      #doc = PdfFilePath.new([attachment.path,attachment_file_type].join('.')).convert_to_document()
      #doc = file.convert_to_document()
      #File.open([attachment.path,'html'].join('.'), 'w') do |f|
      #  f.puts doc.to_s
      #end
    when 'rtf'
      html = RubyRTF::Html.new.convert([attachment.path,attachment_file_type].join('.'))
    	File.open([attachment.path,'html'].join('.'), 'w:UTF-8') do |f|
    	  f.puts html
      end
    else
      File.open([attachment.path,'html'].join('.'), 'w:UTF-8') do |f|
        f.puts "<div class='option error'><h3>#{I18n.t(:error)}</h3><p>#{I18n.t(:no_text_only_convertor_for, :type => attachment_file_type)}</p></div>"
      end
    end
    
  end

  def generate_txt
  	doc = Loofah.fragment(File.open([attachment.path,'html'].join('.'), 'r:UTF-8').read)
  	doc.css('style').remove
  	File.open([attachment.path,'txt'].join('.'), 'w:UTF-8') do |f|
  	  f.puts doc.to_text(:encode_special_chars => false)
  	end 
  end
  
  def generate_cut
    
  	cmd = [
  		AppConfig.swath_bin,
  		'-b','" "','-u','u,u',
  		'<',[attachment.path,'txt'].join('.'),
  		'>',[attachment.path,'cut','txt'].join('.')
  	].join(' ')
  	
  	puts "<Document ##{id}> Generate CUT: $ #{cmd}"
    output = `#{cmd} 2>&1`
    FileUtils.cp  [attachment.path,'txt'].join('.'), [attachment.path,'cut','txt'].join('.')
    #puts "=> #{output}"

  	if output.empty? or output.include?("Segmentation")
  	  #raise SegmentationError, "Segmentation Fault Mother Fucker"
  	  # Temporary fix for MacOSX (western langauges only):
  	  #FileUtils.cp [attachment.path,'txt'].join('.'), [attachment.path,'cut','txt'].join('.')
    end
    
    temp_file = Tempfile.new('ak')
    File.open([attachment.path,'cut','txt'].join('.'), 'r:UTF-8') do |f|
      f.each_line do |line|
	      line.delete!("\u{00A0}+\u{00C2}")
        s = line.split
        temp_file.puts s.join(' ') unless s.empty?
      end
    end
    temp_file.close
    FileUtils.mv temp_file.path, [attachment.path,'cut','txt'].join('.')
  end
 
  def generate_db

    index = 0
    r_start = 0
    r_end = 0
    
    puts "<Document ##{id}> Generate DB"
    words = []
    ranges = []
    
    words_file = File.open([attachment.path,'words','txt'].join('.'), 'w:UTF-8')
    ranges_file = File.open([attachment.path,'ranges','txt'].join('.'), 'w:UTF-8')
    
    File.open([attachment.path,'cut','txt'].join('.'), 'r:UTF-8') do |f|
      f.each_line do |line|
        line.split.each do |word|
          r_start = r_end+1
          r_end += word.length
          word.downcase!
          #word = word.force_encoding('utf-8')
          word.gsub!(/\p{Punct}+/,'')
          #word.sub('', '')
          if word.length > 1
            words << word
            ranges << { :start=> r_start, :end => r_end }
            words_file.puts word
            ranges_file.puts "#{r_start}|#{r_end}"
            index+=1
          end
        end
      end
    end
    
    File.open([attachment.path,'words','obj'].join('.'), 'wb') { |f| f.puts Marshal.dump(words) }
    File.open([attachment.path,'ranges','obj'].join('.'), 'wb') { |f| f.puts Marshal.dump(ranges) }
    
    self.words_length = words.length
    self.content = words.join(' ')
    self.chars_length = content.length
  end
  
  def generate_index
    return if self.from == 'web'
    puts "<Document ##{id}> Generate Index"
    Document.define_indexes
    Document.update_all ['delta = ?', true]#, ['file_id = ?', id]
    Document.index_delta
    #set_file_delta_flag
    self.status = 3
    save! 
  end
  
end
