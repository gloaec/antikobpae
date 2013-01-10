class SimilaritiesController < ApplicationController
  
  before_filter :require_existing_scan_file
  
  def index
  	@similarities = @scan_file.similarities
  end

  def new
  	@similarity = @document.similarities.build
  	@similarity.scan_file_duplicate_range = DuplicateRange.new
  	@similarity.document_duplicate_range = DuplicateRange.new
  end
  
  def create
  	data = params[:similarity]
  	@similarity = @document.similarities.create(data)
  	#@similarity.scan_file_duplicate_range = DuplicateRange.create(data[:scan_file_duplicate_range])
  	#@similarity.document_duplicate_range = DuplicateRange.create(data[:document_duplicate_range])
  	
  	if @similarity.save
  		redirect_to file_similarities_url(@document)      	
  	else
  		render :action => 'new'
  	end 
  end
  
  def require_existing_scan_file
    @scan_file = params[:scan_file_id].blank? ? ScanFile.find(params[:id]) : ScanFile.find(params[:scan_file_id])
    @folder = @scan_file.document.folder
  rescue ActiveRecord::RecordNotFound
    redirect_to scans_url, :alert => t(:already_deleted, :type => t(:this_scan_file))
  rescue NoMethodError
    flash[:alert] = t(:already_deleted, :type => t(:this_method))
  rescue RuntimeError => e
    if e.message == 'This share link expired.'
      flash[:alert] = t(:share_link_expired)
    else
      raise e
    end
  end
  

end
