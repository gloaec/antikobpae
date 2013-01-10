require 'fileutils'
require 'iconv'

class ScanFilesController < ApplicationController
  before_filter :require_existing_file, :only => [:show, :edit, :update, :destroy, :download]
  before_filter :require_existing_target_scan, :only => [:new, :create]

  #before_filter :require_create_permission, :only => [:new, :create]
  #before_filter :require_read_permission, :only => :show
  #before_filter :require_update_permission, :only => [:edit, :update]
  #before_filter :require_delete_permission, :only => :destroy

  # @scan_file / @document / @folder are set in require_existing_file
  def show
    Iconv.open('UTF-8//IGNORE', 'UTF-8') do |ic|
      @document[:content] = ic.iconv(File.open(@document.attachment.path, 'r').read)
    end
  end

  def download
    Iconv.open('UTF-8//IGNORE', 'UTF-8') do |ic|
      @document[:content] = ic.iconv(File.open(@document.attachment.path, 'r').read)
    end
  	respond_to do |format|
  	  format.html do
  	  	send_file @document.attachment.path, :filename => @document.attachment_file_name
  	  end
  	  format.pdf do
  	    render :pdf => @document.attachment_file_name, :wkhtmltopdf => '/usr/local/bin/wkhtmltopdf'
  	  end
  	end
    #send_file @document.attachment.path, :filename => @document.attachment_file_name
  end
  
  # @target_scan is set in require_existing_target_scan
  def new
    @scan_file = @target_scan.scan_files.build
    @scan_file.document[:content] = '<h1>New file</h1>'
  end

  # @target_scan is set in require_existing_target_scan
  def create
  
  	data = params[:document]
    @document = @target_scan.folder.documents.build(data.except(:content))
    
    if @document.save
      
      if data[:content]
        File.open(@document.attachment.path, 'w') do |f|
          f.puts data[:content]
        end
      end
      redirect_to folder_url(@target_folder)
    else
      @document[:content] = data[:content]
      render :action => 'new'
    end
	#end unless params[:document].nil?
    #redirect_to fredit_path(:file => @path)
  end

  # @scan_file / @document / @folder are set in require_existing_file
  def edit
  	Iconv.open('UTF-8//IGNORE', 'UTF-8') do |ic|
  	  @document[:content] = ic.iconv(File.open(@document.attachment.path, 'r').read)
  	end
  end

  # @scan_file / @document / @folder are set in require_existing_file
  def update
  	
  	data = params[:document]
  	 	
    if @document.update_attributes(data.except(:content))
    
      if data[:content]
        File.open(@document.attachment.path, 'w') do |f|
          f.puts data[:content]
        end
      end
      redirect_to edit_file_url(@document), :notice => t(:your_changes_were_saved)
    else
      render :action => 'edit'
    end
  end

  # @document and @folder are set in require_existing_file
  def destroy
    @document.destroy
    redirect_to folder_url(@folder)
  end

  private

  def require_existing_file
    @scan_file = ScanFile.find(params[:id])
    @document = @scan_file.document
    @folder = @document.folder
  rescue ActiveRecord::RecordNotFound
    redirect_to scans_url(), :alert => t(:already_deleted, :type => t(:this_file))
  end
end
