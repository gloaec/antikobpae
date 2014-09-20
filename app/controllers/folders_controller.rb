class FoldersController < ApplicationController
  before_filter :require_existing_folder, :only => [:show, :edit, :update, :destroy, :statement, :files]
  before_filter :require_existing_target_folder, :only => [:new, :create]
  before_filter :require_folder_isnt_root_folder, :only => [:edit, :update, :destroy]

  before_filter :require_create_permission, :only => [:new, :create]
  before_filter :require_read_permission, :only => :show
  before_filter :require_update_permission, :only => [:edit, :update]
  before_filter :require_delete_permission, :only => :destroy

  respond_to :json

  def statement
    render :json => @folder.to_json(:include => {:documents => {:except => :content, :include => { :user => { :only => :name }}}})
  end

  def index
    respond_with(Folder.root)
  end

  # Note: @folder is set in require_existing_folder
  def files
    respond_with @folder.files
  end

  # Note: @folder is set in require_existing_folder
  def show
    respond_with(@folder, include: [:documents, :children])
  end

  # Note: @target_folder is set in require_existing_target_folder
  def new
    @folder = @target_folder.children.build
  end

  # Note: @target_folder is set in require_existing_target_folder
  def create
    @folder = @target_folder.children.build(params[:folder])
	  @folder.private = @target_folder.private
	  @folder.user = current_user
	
    if @folder.save
      #respond_with(@folder, status: :created, location: @folder)
      redirect_to folder_url(@target_folder)
    else
      render :action => 'new'
      #respond_with(@folder.errors, status: :unprocessable_entity) 
    end
  end

  # Note: @folder is set in require_existing_folder
  def edit
  end

  # Note: @folder is set in require_existing_folder
  def update
  	params[:folder][:user] = current_user
    if @folder.update_attributes(params[:folder])
      #respond_with(@folder)
      redirect_to edit_folder_url(@folder), :notice => t(:your_changes_were_saved)
    else
      #respond_with(@folder.errors, status: :unprocessable_entity)
      render :action => 'edit'
    end
  end

  # Note: @folder is set in require_existing_folder
  def destroy
    target_folder = @folder.parent
    @folder.destroy
    redirect_to folder_url(target_folder)
  end

  private

  def require_existing_folder
    @folder = Folder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to folder_url(Folder.root), :alert => t(:already_deleted, :type => t(:this_folder))
  end

  def require_folder_isnt_root_folder
    if @folder.is_root?
      redirect_to folder_url(Folder.root), :alert => t(:cannot_delete_root_folder)
    end
  end

  # Overrides require_delete_permission in ApplicationController
  def require_delete_permission
    unless @folder.is_root? || current_user.can_delete(@folder)
      redirect_to folder_url(@folder.parent), :alert => t(:no_permissions_for_this_type, :method => t(:delete), :type =>t(:this_folder))
    else
      require_delete_permissions_for(@folder.children)
    end
  end

  def require_delete_permissions_for(folders)
    folders.each do |folder|
      unless current_user.can_delete(folder)
        redirect_to folder_url(@folder.parent), :alert => t(:no_delete_permissions_for_subfolder)
      else
        # Recursive...
        require_delete_permissions_for(folder.children)
      end
    end
  end
end
