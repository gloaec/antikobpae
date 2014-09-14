class HomeController < ApplicationController

  def index
  	@folder = current_user.scans_folder
  	@scans = []
    @folder.children.each do |folder|
    	@scans << folder.scan
    end
    @scans.sort! { |a,b| b.created_at <=> a.created_at }
    @scan_files = @scans.map {|scan| scan.scan_files }.flatten
  end
end
