# encoding: utf-8

class Similarity < ActiveRecord::Base

  belongs_to :scan_file_duplicate_range, :class_name => "DuplicateRange", :foreign_key => 'scan_file_duplicate_range_id'
  belongs_to :document_duplicate_range, :class_name => "DuplicateRange", :foreign_key => 'document_duplicate_range_id'
  
  belongs_to :document#, :through => :document_duplicate_range
  belongs_to :scan_file#, :through => :scan_file_duplicate_range
  
  accepts_nested_attributes_for :scan_file_duplicate_range, :reject_if => :all_blank
  accepts_nested_attributes_for :document_duplicate_range, :reject_if => :all_blank
  
  attr_accessible :scan_file_duplicate_range, :document_duplicate_range, :scan_file, :document, :is_exception, :is_validated

  validates_presence_of [:document,:scan_file]

  scope :by_document, lambda {|document| {:conditions => {:document_id => document.id}}}
  
  def scan_file_highlight
    sfhdbw = Marshal.load(File.open([scan_file.document.attachment.path,'words','obj'].join('.')))
    #STDERR.printf("open error: %s\n", sfhdbw.errmsg(sfhdbw.ecode)) unless sfhdbw.open([scan_file.document.attachment.path,'word','tch'].join('.'), HDB::OREADER)
    margin = 50
    s = []
    start = scan_file_duplicate_range.from_word-margin
    start = 0 if start < 0 
    for i in (start..scan_file_duplicate_range.to_word+margin)
      s << "<span class='duplicated'>" if i == scan_file_duplicate_range.from_word
      s << sfhdbw[i]
      s << "</span>" if i == scan_file_duplicate_range.to_word
    end
    #STDERR.printf("close error: %s\n", sfhdbw.errmsg(sfhdbw.ecode)) unless sfhdbw.close
    s.join(' ').html_safe.force_encoding('utf-8')
  end
  
  def document_highlight
    ufhdbw = Marshal.load(File.open([document.attachment.path,'words','obj'].join('.')))
    #STDERR.printf("open error: %s\n", ufhdbw.errmsg(ufhdbw.ecode)) unless ufhdbw.open([document.attachment.path,'word','tch'].join('.'), HDB::OREADER)
    margin = 50
    s = []
    start = document_duplicate_range.from_word-margin
    start = 0 if start < 0
    for i in (start..document_duplicate_range.to_word+margin)
      s << "<span class='duplicated source_#{document.id}'>" if i == document_duplicate_range.from_word
      s << ufhdbw[i]
      s << "</span>" if i == document_duplicate_range.to_word
    end
    #STDERR.printf("close error: %s\n", ufhdbw.errmsg(ufhdbw.ecode)) unless ufhdbw.close
    s.join(' ').html_safe.force_encoding('utf-8')
  end
  
  def merge_with(similarity)
  	if scan_file_duplicate_range.includes_range?(similarity.scan_file_duplicate_range) \
  	  && document_duplicate_range.includes_range?(similarity .document_duplicate_range) 	# Includes
  		true
  	elsif similarity.scan_file_duplicate_range.includes_range?(scan_file_duplicate_range) \
  	  && similarity.document_duplicate_range.includes_range?(document_duplicate_range)	# Is Included
  		scan_file_duplicate_range.from_word = similarity.scan_file_duplicate_range.from_word
  		scan_file_duplicate_range.to_word = similarity.scan_file_duplicate_range.to_word
  		document_duplicate_range.from_word = similarity.document_duplicate_range.from_word
  		document_duplicate_range.to_word = similarity.document_duplicate_range.to_word
  		true
  	elsif scan_file_duplicate_range.embraces_range?(similarity.scan_file_duplicate_range) \
  	  && document_duplicate_range.embraces_range?(similarity.document_duplicate_range)	# Embraces
  		scan_file_duplicate_range.to_word = similarity.scan_file_duplicate_range.to_word
  		document_duplicate_range.to_word = similarity.document_duplicate_range.to_word
  		true
  	elsif similarity.scan_file_duplicate_range.embraces_range?(scan_file_duplicate_range) \
  	  && similarity.document_duplicate_range.embraces_range?(document_duplicate_range)	# Is Embraced
  		scan_file_duplicate_range.from_word = similarity.scan_file_duplicate_range.from_word
  		document_duplicate_range.from_word = similarity.document_duplicate_range.from_word
  		true
  	end
  	false
  end
end
