class DuplicateRange < ActiveRecord::Base

  has_one :similarity, :dependent => :destroy
  has_one :document, :dependent => :destroy, :through => :similarity
  has_one :scan_file, :dependent => :destroy, :through => :similarity
  
  def words_length
  	to_word-from_word
  end

  def chars_length
    to_char-from_char
  end

  def includes?(pos)
  	from_word <= pos && pos <= to_word
  end
  
  def includes_range?(dup_range)
   	from_word <= dup_range.from_word && dup_range.to_word <= to_word
  end

  def embraces_range?(dup_range)
  	from_word <= dup_range.from_word && dup_range.from_word <= to_word && to_word <= dup_range.to_word
  end
  
  
end
