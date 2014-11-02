class Folder < ActiveRecord::Base
  acts_as_tree :order => 'name'

  has_many :documents, :dependent => :destroy, :order => 'attachment_file_name'
  has_many :group_folder_permissions, :dependent => :destroy
  has_many :user_folder_permissions, :dependent => :destroy
  
  belongs_to :user
  has_one :private_folder
  has_one :scans_folder 
  has_one :scan
  has_many :scans
  has_one :domain
  
  accepts_nested_attributes_for :documents, :parent, :children
  
  attr_accessor :is_copied_folder
  attr_accessible :name, :user_id, :private, :documents, :parent
  

  validates_uniqueness_of :name, :scope => :parent_id
  validates_presence_of :name

  before_save :check_for_parent
  after_create :create_permissions, :unless => :is_copied_folder
  before_destroy :dont_destroy_root_folder

  def as_json(options={})
    options = options.merge({})
    json = super(options)
    json[:parent] = self.parent.as_json
    json
  end

  def files
    folders = self.children.as_json.map {|folder| folder[:type] = '_folder'; folder}
    documents = self.documents.as_json.map {|document| document[:type] = 'document'; document}
    folders + documents
  end

  def copy(target_folder, originally_copied_folder = nil)
    new_folder = self.dup
    new_folder.is_copied_folder = true
    new_folder.parent = target_folder
    new_folder.save!

    originally_copied_folder = new_folder if originally_copied_folder.nil?

    # Copy original folder's permissions
    self.group_folder_permissions.each do |permission|
      new_permission = permission.dup
      new_permission.folder = new_folder
      new_permission.save!
    end
    
    self.user_folder_permissions.each do |permission|
      new_permission = permission.dup
      new_permission.folder = new_folder
      new_permission.save!
    end

    self.documents.each do |file|
      file.copy(new_folder)
    end

    # Copy sub-folders recursively
    self.children.each do |folder|
      folder.copy(new_folder, originally_copied_folder) unless folder == originally_copied_folder
    end

    new_folder
  end

  def move(target_folder)
    unless target_folder == self || self.parent_of?(target_folder)
      self.parent = target_folder
      save!
    else
      raise 'You cannot move a folder to its own sub-folder.'
    end
  end

  def parent_of?(folder)
    self.children.each do |child|
      if child == folder
        return true
      else
        return child.parent_of?(folder)
      end
    end
    false
  end

  def is_root?
    parent.nil? && !new_record?
  end

  def is_index?
    parent_id == 1 && !new_record?
  end

  def self.root
    find_by_name_and_parent_id('Root folder', nil)
  end

  def self.index
    find_by_name_and_parent_id('Web Index', 1)
  end

  def has_children?
    children.count > 0
  end

  private

  def check_for_parent  	
    raise 'Folders must have a parent.' if parent.nil? && name != 'Root Folder'
  end

  def create_permissions
    unless is_root?
      parent.group_folder_permissions.each do |permission|
        GroupFolderPermission.create! do |p|
          p.group = permission.group
          p.folder = self
          p.can_create = permission.can_create && !self.private || permission.group.admins_group?
          p.can_read   = permission.can_read && !self.private || permission.group.admins_group?
          p.can_update = permission.can_update && !self.private || permission.group.admins_group?
          p.can_delete = permission.can_delete && !self.private || permission.group.admins_group? || permission.can_update && permission.can_create
        end
      end
      parent.user_folder_permissions.each do |permission|
        UserFolderPermission.create! do |p|
          p.user = permission.user
          p.folder = self
          p.can_create = permission.can_create
          p.can_read   = permission.can_read unless permission.folder.is_root?
          p.can_update = permission.can_update
          p.can_delete = permission.can_delete || permission.can_update && permission.can_create
        end
      end
    end
  end

  def dont_destroy_root_folder
    raise "Can't delete Root folder" if is_root?
  end
end
