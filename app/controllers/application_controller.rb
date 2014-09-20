class ApplicationController < ActionController::Base
  
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  
  protect_from_forgery
  
  before_filter :set_locale
  before_filter :require_admin_in_system
  before_filter :authenticate_user!

  helper_method :clipboard#, :current_user, :signed_in?

  def index
  end

  def stats
    webpages = Document.where(attachment_file_type: 'html').count
    documents = Document.count - webpages
    scanfiles = ScanFile.count 
    connections = Similarity.count('document_id, scan_file_id', distinct: true)
    similarities = Similarity.count
    tasks = Delayed::Job.count
    stats = {
        documents:    documents,
        webpages:     webpages,
        scanfiles:    scanfiles,
        connections:  connections,
        similarities: similarities,
        tasks:        tasks
    }
    render json: stats.to_json
  end

  def set_locale 
    I18n.locale = params[:locale] || session[:locale] || cookies[:locale] || I18n.default_locale 
    session[:locale] = I18n.locale
    cookies[:locale] = I18n.locale
  end

  protected

  def clipboard
    session[:clipboard] ||= Clipboard.new
  end

  private 
  
  def require_admin_in_system
    redirect_to new_user_registration_url if User.no_admin_yet?
  end

  def require_admin
    redirect_to :root unless current_user.member_of_admins?
  end

  def require_existing_target_folder
  	if(params[:scan_id])
		params[:folder_id] = Scan.find(params[:scan_id]).folder
	end
    @target_folder = Folder.find(params[:folder_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to folder_url(Folder.root), :alert => t(:already_deleted, :type => t(:this_folder)+" | #{params[:folder_id]} | #{params[:scan_id]}")
  end
  
  def require_existing_target_scan
    @target_scan = Scan.find(params[:scan_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to scans_path, :alert => t(:already_deleted, :type => t(:this_scan)+" #{params}")
  end
  
  def require_existing_file
    @document = Document.find(params[:id])
    @folder = @document.folder
  rescue ActiveRecord::RecordNotFound
    redirect_to folder_url(Folder.root), :alert => t(:already_deleted, :type => t(:this_file))
  end

  def require_create_permission
    unless current_user.can_create(@target_folder)
      redirect_to folder_url(@target_folder), :alert => t(:no_permissions_for_this_type, :method => t(:create), :type => t(:this_folder))
    end
  end

  %w{read update delete}.each do |method|
    define_method "require_#{method}_permission" do
      unless (method == 'read' && @folder.is_root?) || current_user.send("can_#{method}", @folder)
        redirect_folder = @folder.parent.nil? ? Folder.root : @folder.parent
        redirect_to folder_url(redirect_folder), :alert => t(:no_permissions_for_this_type, :method => t(:create), :type => t(:this_folder))
      end
    end
  end
end
