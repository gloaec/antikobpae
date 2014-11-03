class ScansController < ApplicationController
  
  before_filter :require_existing_scan, :only => [:show, :edit, :update, :destroy, :start, :statement]
  before_filter :require_existing_folder, :only => [:index, :new, :create]
  before_filter :require_existing_scan_folder, :only => [:show, :edit, :update, :destroy, :start, :statement]
  
  before_filter :require_create_permission, :only => [:new, :create]
  before_filter :require_read_permission, :only => :show
  before_filter :require_update_permission, :only => [:edit, :update]
  before_filter :require_delete_permission, :only => :destroy
  
  respond_to :json

  def statements
    @folder = current_user.scans_folder
  	@scans = []
    @folder.children.each do |folder|
    	@scans << folder.scan
    end
    respond_with @scans.to_json(:include => {:scan_files => {:methods => [:count_sources , :count_file_sources, :count_web_sources, :count_recursive_sources]}})
  end
  
  def statement 
    respond_with @scan.to_json(:include => {:scan_files => {:methods => [:count_sources , :count_file_sources, :count_web_sources, :count_recursive_sources]}})
  end

  def start 
     @scan.scan_files.destroy_all unless @scan.scan_files.empty?
     
     @scan.folder.documents.each do |file|
     	 @scan.scan_files.build(:document => file, :progress => 0, :status => 0, :score => 0)
     end
     
     if @scan.save
       @scan.start
  	   render :action => 'show'#redirect_to scan_url(@scan)
  	   return
  	 else
  	   render :action => 'edit'
  	 end
  end
  
  def index
    @folder = current_user.scans_folder
    @scans = []
    @folder.children.each do |folder|
      @scans << folder.scan
    end
    @scans.sort! { |a,b| b.updated_at <=> a.updated_at }
    if params[:limit]
      @scans = @scans.first(params[:limit].to_i)
    end
    respond_with @scans.to_json(
      :methods => [
        :progress,
        :count_documents,
        :count_pending,
        :count_passed,
        :count_suspicious,
        :count_plagiarized,
        :count_similarities,
        :count_sources
      ]
    )
  end

  def new
  	t = Time.now
  	@folder = current_user.scans_folder
  	@scan = @folder.scans.create(params[:scan])
  	@scan.folder = current_user.scans_folder.children.create(:name => [t.strftime("Scan %m/%d/%Y %H:%M"),SecureRandom.hex(3)]*'-')
  	if @scan.save
  	  redirect_to edit_scan_url(@scan)#render :action => 'edit'
    else
      redirect_to scans_url
    end
  end
  
  def create
  	@folder = current_user.scans_folder
  	@scan = @folder.scans.create(params[:scan]) 
    @scan.folder = current_user.scans_folder.children.build(params[:folder])
    
    if @scan.save
      redirect_to edit_scan_url(@scan)
    else
      render :action => 'new'
    end
  end

  # Note: @scan is set in require_existing_scan
  def show
  end
  
  # Note: @scan is set in require_existing_scan
  def edit
  end

  # Note: @scan is set in require_existing_scan
  def update
    if @scan.update_attributes(params[:scan]) && @scan.folder.update_attributes(params[:folder])
      if params[:start] == "1"
        start#redirect_to start_scan_url(@scan)
      else
        redirect_to edit_scan_url(@scan), :notice => t(:your_changes_were_saved) 
      end  
    else
      render :action => 'edit'
    end
  end

  # Note: @scan is set in require_existing_scan
  def destroy
    target_folder = @scan.folder.parent
    @scan.folder.destroy
    @scan.destroy
    redirect_to folder_url(target_folder)
  end

  private

  def require_existing_folder
    @folder = current_user.scans_folder
  rescue ActiveRecord::RecordNotFound
    redirect_to folder_url(Folder.root), :alert => t(:already_deleted, :type => t(:this_folder))
  end  
  
  def require_existing_scan
    @scan = Scan.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to scans_url, :alert => t(:scan_already_deleted)
  end
  
  def require_existing_scan_folder
    @folder = @scan.folder
  rescue ActiveRecord::RecordNotFound
     redirect_to folder_url(Folder.root), :alert => t(:already_deleted, :type => t(:this_folder))
  end
  
  def require_create_permission
    unless current_user.can_create(@folder)
      redirect_to folder_url(@folder), :alert => t(:no_permissions_for_this_type, :method => t(:create), :type => t(:this_folder))
    end
  end
  
end
