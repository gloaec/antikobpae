module SimilaritiesHelper
  def colorSet(col, results=8, slices=30)
    return [] if slices <= 0
    color = Color::RGB.from_html(col)
    part = 360 / slices
    ret = [color]
    hsl = color.to_hsl
    hsl.hue = ((hsl.hue - (part * results >> 1)) + 720) % 360
    while results > 1
      hsl.hue += part
      hsl.hue %= 360
      results -= 1
      ret << hsl.to_rgb
    end
    ret
  end
  
  def rgba(color, alpha)
    "rgba(#{color.red.to_i},#{color.green.to_i},#{color.blue.to_i},#{alpha})"
  end
  
  def colors(nb)
    html = []
    colorSet("#FE008F",nb,nb).each_with_index do |color, index|
      html << "<div style='position: absolute; left: 40px; right: 40px; width:200px; height: 200px; background: #{rgba(color, 0.5)};'> COLOR ##{index}"
    end
    for i in (0..nb)
      html << "</div>"
    end
    html.join.html_safe
  end
  
  def calculate_score(similarities)
    s = similarities.first
    scan_file, document = s.scan_file, s.document
    doc_dup_words, src_dup_words = 0, 0
    doc_dup_chars, src_dup_chars = 0, 0
    doc_word_ranges = similarities.map { |sim| (sim.scan_file_duplicate_range.from_word..sim.scan_file_duplicate_range.to_word) } 
    doc_char_ranges = similarities.map { |sim| (sim.scan_file_duplicate_range.from_char..sim.scan_file_duplicate_range.to_char) }
    src_word_ranges = similarities.map { |sim| (sim.document_duplicate_range.from_word..sim.document_duplicate_range.to_word) } 
    src_char_ranges = similarities.map { |sim| (sim.document_duplicate_range.from_char..sim.document_duplicate_range.to_char) }
    merge_ranges(doc_word_ranges).each { |range| doc_dup_words += range.to_a.size }
    merge_ranges(doc_char_ranges).each { |range| doc_dup_chars += range.to_a.size }
    merge_ranges(src_word_ranges).each { |range| src_dup_words += range.to_a.size }
    merge_ranges(src_char_ranges).each { |range| src_dup_chars += range.to_a.size }
    doc_word_score = doc_dup_words.to_f*100.0/(scan_file.document.words_length.to_f-1)
    doc_char_score = doc_dup_chars.to_f*100.0/(scan_file.document.chars_length.to_f-1)
    src_word_score = src_dup_words.to_f*100.0/(document.words_length.to_f-1)
    src_char_score = src_dup_chars.to_f*100.0/(document.chars_length.to_f-1)
    { 
      :doc => { 
        :word_score => doc_word_score, 
        :char_score => doc_char_score, 
        :score => (doc_word_score + doc_char_score) / 2.0 
      },
      :src => { 
        :word_score => src_word_score, 
        :char_score => src_char_score, 
        :score => (src_word_score + src_char_score) / 2.0 
      }
    }
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
end
