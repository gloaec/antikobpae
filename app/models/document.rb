# encoding: utf-8
require 'ruby-rtf'
require 'nokogiri'
require 'tempfile'
require 'fileutils'
require 'thinking_sphinx'

include ActionView::Helpers::TextHelper

class EncodeError < RuntimeError; end
class SegmentationError < RuntimeError; end
class ConversionError < RuntimeError; end

class Document < ActiveRecord::Base
  has_attached_file :attachment, :path => "#{AppConfig.storage_path}/:rails_env/:id/:style/content"
  belongs_to :folder
  belongs_to :user
  has_one :scan_file, :dependent => :destroy
  has_one :content, :dependent => :destroy
  has_many :share_links, :dependent => :destroy
  has_many :duplicate_ranges, :through => :similarities, :foreign_key => "document_duplicate_range"
  has_many :similarities, :dependent => :destroy
  has_many :images
  has_many :metadatas
  
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :metadatas
  accepts_nested_attributes_for :content
 
  validate :check_file
  validates_attachment_presence :attachment, :message => I18n.t(:blank, :scope => [:activerecord, :errors, :messages])
  validates_presence_of [:folder_id, :name]
  validates_format_of :name, :with => /^[^\/\\\?\*:|"<>]+$/, :message => I18n.t(:invalid_characters, :scope => [:activerecord, :errors, :messages])
  validates_format_of :attachment_file_type, :with => %r{^(file|docx|doc|pdf|odt|txt|html|rtf)$}i, :message => I18n.t(:file_format_not_supported)
  validates_uniqueness_of :name, :scope => 'folder_id', :message => I18n.t(:exists_already, :scope => [:activerecord, :errors, :messages])

  do_not_validate_attachment_file_type :attachment

  after_save :prepare_processing
  
  def as_json(options={})
    options = options.merge({})
    json = super(options)
    json[:folder] = self.folder.as_json
    json
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
    self.update_attribute(:folder, target_folder)
  end
  
  def extension
    self.attachment_file_type
  end
  
  def destroy
    scan_files = Similarity.by_document(self).map { |s| s.scan_file }.uniq
    FileUtils.rm_rf File.dirname(self.attachment.path)
    FileUtils.rm_rf "#{Rails.root}/uploads/#{Rails.env}/#{id}" if Dir["#{Rails.root}/uploads/#{Rails.env}/#{id}/*"].empty?
    super
    scan_files.each {|sf| sf.calculate_score }
  end
  
  def process_document
    puts "==========================================================================="
    puts "<Document ##{id}> Processing Document..."
    generate_html
    generate_txt
    generate_cut
    generate_db
    generate_index
    puts "==========================================================================="
  end

  private 
  
  def check_file
    self.attachment_file_type = self.attachment_file_type \
    || File.extname(attachment_file_name)[1..-1] unless self.attachment_file_name.nil? 
  end
  
  def prepare_processing
    if status < 2
      unless File.exists?(attachment.path)
          FileUtils.mkdir_p File.dirname(attachment.path)
          FileUtils.touch attachment.path
      end
      
      if attachment_file_type == 'file'
        FileUtils.cp attachment.path, [attachment.path,'html'].join('.')
      end

      case self.from
        when 'web'  then self.delay(:queue => 'indexer').process_document
        when 'scan' then self.delay(:queue => 'scans').process_document
        else             self.delay(:queue => 'documents').process_document
      end
    end
  end

  def generate_utf8(encoding=nil)  
       
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
      
      cmd = [
        [Rails.root,'bin','thaiconv'].join('/'),
        '-r', attachment.path,
        '-out',1,'>',[attachment.path, attachment_file_type].join('.')
      ].join(' ')

      puts "<Document ##{id}> Converting #{encoding} to UTF-8 : #{cmd}"
      output = `#{cmd} 2>&1`

    else
      FileUtils.mv attachment.path, [attachment.path,attachment_file_type].join('.')
    end
  end
	
  def generate_html

    self.update_attribute(:status, 2)

    case attachment_file_type
    when 'txt'
      generate_utf8
      FileUtils.cp [attachment.path,attachment_file_type].join('.'), [attachment.path,'html'].join('.')
    when 'file'
      #not performed by delayed jobs
      #FileUtils.cp attachment.path, [attachment.path,'html'].join('.')
    when 'html'  
	    
	    #unless self.from == 'web' or
      unless File.exists?([attachment.path,'html'].join('.'))
	    
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

  	puts "<Document ##{id}> Retrieving contents from: #{self.attachment_file_name}"
	
  	begin
  	    file = open(uri)
  	    File.open(attachment.path, "wb") do |f|
  	      f.write file.read
            end
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
          uri = self.attachment_file_name
          retries -= 1
          retry if retries > 1
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
      
      doc = Nokogiri::HTML(File.open([attachment.path,'html'].join('.'),'r:UTF-8').read, nil, 'UTF-8')
      
      self.name = title = doc.css('title').inner_text.gsub(/[\/\\\?\*:|"<>]+/, ' ') unless doc.css('title').blank?
      
      count = 1
      until self.folder.documents.find_by_name(self.name).nil? 
        self.name = "#{title} (#{count})"
        count += 1
      end
      
      doc.xpath("//meta").each do |tag|
        unless tag.attributes['name'].nil? or tag.attributes['content'].nil?
          metadatas.create(:key => tag.attributes['name'].to_s, :value => tag.attributes['content'].to_s)
        end
      end
      doc.search('head','script','style','link').remove
      doc.xpath('//@style').each(&:remove)
      doc.xpath('//@class').each(&:remove)
      doc.xpath('//@id').each(&:remove)

	    File.open([attachment.path,'html'].join('.'), 'wb') do |f|
	      f.puts doc.css('body').inner_html
      end
	  else

	    return if File.exists?([attachment.path,attachment_file_type].join('.')) #self.status > 1
	    
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

    self.update_attribute(:status, 2)
    self.update_attribute(:attachment_file_size, File.size([attachment.path,'html'].join('.')))
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
        self.update_attribute(:status, -1)
      end
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
  	doc = Nokogiri::HTML(File.open([attachment.path,'html'].join('.'),'r:UTF-8').read, nil, 'UTF-8')
    #Loofah.fragment(File.open([attachment.path,'html'].join('.'), 'r:UTF-8').read)
  	doc.css('style').remove
  	File.open([attachment.path,'txt'].join('.'), 'w:UTF-8') do |f|
  	  f.puts Nokogiri::HTML(CGI.unescapeHTML(doc.inner_text)).content #.to_text(:encode_special_chars => false)
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
	      #line.delete!("\u{00A0}+\u{00C2}")
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
	  word.gsub!(/[^0-9a-z ]/i, '')
          word.gsub!(/\p{Punct}+/,'')
          word.gsub!(/(\s|\u00A0)+/, '')
          if word.length >= 1
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
    content_text = words.join(' ')

    unless content_text.nil?
      if self.content.nil? 
        self.content = Content.create(:text => content_text)
      else
        self.content.update_attributes(:text => content_text, :delta => true)
      end
    end

    self.chars_length = content_text.length
    self.status = 3
    save! 
  end
  
  def generate_index
  #   puts "<Document ##{id}> Generate Index"
  #   self.status = 3
  #   unless(self.content.nil?)
  #     self.delta = true
  #   end
  end
end
