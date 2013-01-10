require 'fileutils'
require 'iconv'

class DocumentsController < ApplicationController
  before_filter :require_existing_file, :only => [:show, :edit, :update, :destroy, :download, :image]
  before_filter :require_html_content, :only => [:show, :edit, :download]
  before_filter :require_existing_target_folder, :only => [:new, :create]
  #before_filter :require_existing_target_scan, :only => [:new, :create]

  before_filter :require_create_permission, :only => [:new, :create]
  before_filter :require_read_permission, :only => :show
  before_filter :require_update_permission, :only => [:edit, :update]
  before_filter :require_delete_permission, :only => :destroy

  # @document and @folder are set in require_existing_file
  def show
  end
  
  def xmlpipe
    @records = Document.all
    render :xml => @records.to_xml
  end
  
  def image
    render :xml => File.open([File.dirname(@document.attachment.path), 'images', 1].join('/'), 'r').read 
  end

  def download
  	respond_to do |format|
  	  format.orig do
  	  	send_file [@document.attachment.path,@document.attachment_file_type].join('.'), :filename => [@document.name,@document.attachment_file_type].join('.')
  	  end
  	  format.html do
  	  	send_file [@document.attachment.path,'html'].join('.'), :filename => [@document.name,'html'].join('.')
  	  end
  	  format.text do
  	  	send_file [@document.attachment.path,'txt'].join('.'), :filename => [@document.name,'txt'].join('.')
  	  end
  	  format.pdf do
  	    render :pdf => @document.name, :wkhtmltopdf => AppConfig.wkhtmltopdf_bin
  	  end
  	end
    #send_file @document.attachment.path, :filename => @document.attachment_file_name
  end
  
  # @target_folder is set in require_existing_target_folder
  def new
    @document = @target_folder.documents.build(:content => '<h1>New Document</h1>')
    @document[:name] = nil
  end

  # @target_folder is set in require_existing_target_folder
  def create
    
  	newparams = coerce(params) 
  	
  	puts "------"
  	puts newparams.inspect
  	puts "------"
  	
    @document = @target_folder.documents.build(newparams[:document])

    #@document = @target_folder.documents.build(data)   
    @document.status = 0
    @document.from = @target_folder.parent == current_user.scans_folder ? 'scan' : 'file'
    @document.user = current_user
    #@document.attachment_file_type = @document.extension || 'file' unless @document.attachment_file_name.nil?

    case params[:from]
    when 'upload' 
      @document.name = File.basename(@document.attachment_file_name, File.extname(@document.attachment_file_name)).sub(/_/,' ') if @document.name.blank? && !@document.attachment_file_name.blank? 
    when 'scratch'
      @document.attachment_file_name = [@document.name,'file'].join('.')
    when 'webpage'
      require 'open-uri'
      @document.attachment_file_type = 'html'
      uri = URI.parse(URI::escape(@document.attachment_file_name))
      @document.name = [uri.host,'-',ActiveSupport::SecureRandom.hex(6)].join 
    end
    
    if @document.save
      flash[:notice] = "Successfully uploaded document."
      respond_to do |format| 
        format.html { redirect_to folder_url(@target_folder) } 
        format.json  { render :json => { :result => 'success', :upload => document_path(@document) } } 
      end	
    else
    	@document[:content] = newparams[:document][:content]
    	@document[:attachment] = newparams[:document][:attachment]
      @document[:name] = newparams[:document][:name]
      flash[:notice] = "Only gif, jpg or png files allowed"
      respond_to do |format| 
        format.html { render :action => 'new' } 
        format.json  { render :json => { :result => 'failed' } } 
      end
    end  
      
	#end unless params[:document].nil?
    #redirect_to fredit_path(:file => @path)
  #rescue ConversionError
  #	redirect_to folder_url(@target_folder), :alert => t(:conversion_problem, :type => t(:this_file))
  end

  # @document and @folder are set in require_existing_file
  def edit
  end

  # @document and @folder are set in require_existing_file
  def update
  	
  	data = params[:document]
  	data[:status] = 0
  	data[:user] = current_user
  		  	
    if @document.update_attributes(data)
      redirect_to edit_document_url(@document), :notice => t(:your_changes_were_saved)
    else
      render :action => 'edit'
    end
  end

  # @document and @folder are set in require_existing_file
  def destroy
    @document.destroy
    redirect_to folder_url(@folder)
  end

  def coerce(params) 
    if params[:document].nil? 
      h = Hash.new 
      h[:document] = Hash.new 
      h[:document][:attachment] = params[:file] 
      h[:document][:name] = params[:name] 
      h[:document][:text_only] = params[:document_text_only]
      #h[:upload][:data].content_type =  MIME::Types.type_for(h[:upload][:data].original_filename).to_s 
      h 
    else 
      params
    end 
  end

  private

  def require_existing_file
    @document = Document.find(params[:id])
    @folder = @document.folder
  rescue ActiveRecord::RecordNotFound
    redirect_to folder_url(Folder.root), :alert => t(:already_deleted, :type => t(:this_file))
  end
  
  def require_html_content
    @document[:content] = File.open([@document.attachment.path,'html'].join('.'), 'r:UTF-8').read 
  rescue Errno::ENOENT
    redirect_to folder_url(@folder), :alert => t(:already_deleted, :type => t(:this_content)+[@document.attachment.path,'html'].join('.'))
  end
end
