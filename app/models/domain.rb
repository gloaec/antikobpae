# encoding: UTF-8
require 'anemone'
include ActionView::Helpers::TextHelper 

class Domain < ActiveRecord::Base
  belongs_to :folder, :dependent => :destroy
    

  attr_accessible :folder
  accepts_nested_attributes_for :folder

  def crawl(seed_uri, path)
    path_folder = folder.children.find_by_name(path) || folder.children.create(:name => path)
    uri = nil

    begin
      uri = URI.parse(URI.escape(seed_uri))
    rescue URI::InvalidURIError
      require 'cgi'
      uri = URI.parse(CGI.escape(seed_uri))
    end

    Anemone.crawl(uri, :discard_page_bodies => true, :threads => 8) do |anemone|
      #anemone.focus_crawl { |page| page.links.slice(0..1) }
      #anemone.on_every_page do |page|
      puts 'Crawling '+uri.to_s+'...'
      #anemone.storage = Anemone::Storage.MongoDB 

      #anemone.on_every_page do |page|

      anemone.on_pages_like(/\/?#{Regexp.escape(path)}\/.*$/) do |page|
          puts page.url

          name = page.doc.at('title').inner_html.gsub(/[\/\\\?\*:|"<>]+/, ' ') unless page.doc.nil? or page.doc.at('title').nil?
          name = title = name \
          || truncate(page.url.to_s, :length => 40, :omission => '...').gsub(/[\/\\\?\*:|"<>]+/, ' ') \
          || ["Unknown",'-',SecureRandom.hex(6)].join

          count = 1
          until path_folder.documents.find_by_name(name).nil?
            name = "#{title} (#{count})"
            count += 1
          end

          # tempfile = Tempfile.new('indexer', Rails.root.join('tmp') )
          # tempfile.binmode
          # tempfile.write page.body
          # tempfile.close

          source = path_folder.documents.create({
            :from => 'web',
            :status => 0,
            :text_only => true,
            #:attachment => File.open(tempfile.path),
            :attachment_file_type => 'html',
            :attachment_file_name => page.url.to_s,
            :name => name
          })
          #source.save!

      end

    end

  end
  
handle_asynchronously :crawl, :queue => 'crawler'


end
