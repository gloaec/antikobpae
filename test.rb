require 'anemone'

Anemone.crawl("http://en.wikipedia.org/wiki/Plagiarism") do |anemone|
anemone.focus_crawl { |page| page.links.slice(0..1) }
  anemone.on_every_page do |page|
      puts page.url
      page.links.each do |link|
        puts '     '+link.to_s
    end
  end
end
