class User < ActiveRecord::Base

  devise :database_authenticatable, #:ldap_authenticatable, 
        :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :groups
  has_many :documents
  has_many :folders
  has_many :user_folder_permissions, :dependent => :destroy
  belongs_to :private_folder, :class_name => "Folder" 
  belongs_to :scans_folder, :class_name => "Folder" #, :foreign_key => "scans_folder_id"

  #attr_accessor :password_confirmation, :password_required, :dont_clear_reset_password_token
  attr_accessible :name, :email, :is_admin, :password, :password_confirmation, :password_required

  validates_presence_of :name, :email
  validates_uniqueness_of :name, :email
=begin
  validates_confirmation_of :password
  validates_length_of :password, :in => 6..20, :allow_blank => true
  validates_presence_of :password, :if => :password_required
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/

  before_save :clear_reset_password_token, :unless => :dont_clear_reset_password_token
=end  
  after_create :create_root_folder_and_admins_group, :if => :is_admin
  after_create :create_personnal_and_scan_folders
  after_create :create_admin_permissions, :if => :is_admin
  after_create :create_permissions, :unless => :is_admin
  
  before_destroy :dont_destroy_admin

  def as_json(options={})
    options = options.merge({})
    json = super(options)
    json[:scans_folder] = self.scans_folder.as_json
    json[:private_folder] = self.private_folder.as_json
    json
  end

  %w{create read update delete}.each do |method|
  	define_method "can_#{method}" do |folder|
  	  has_permission = false
  	  groups.each do |group|
  	    unless group.group_folder_permissions.send("find_by_folder_id_and_can_#{method}", folder.id, true).blank?
  	      has_permission = true
  	      break
  	    end
  	  end
  	  unless self.user_folder_permissions.send("find_by_folder_id_and_can_#{method}", folder.id, true).blank?
  	      has_permission = true
  	  end
  	  has_permission
  	end
    define_method "can_user_#{method}" do |folder|
      has_permission = false
      unless self.user_folder_permissions.send("find_by_folder_id_and_can_#{method}", folder.id, true).blank?
          has_permission = true
      end
      has_permission
    end
    define_method "can_groups_#{method}" do |folder|
      has_permission = false
      groups.each do |group|
        unless group.group_folder_permissions.send("find_by_folder_id_and_can_#{method}", folder.id, true).blank?
          has_permission = true
          break
        end
      end
      has_permission
    end
  end

  def valid_password?(password)
    super
  rescue BCrypt::Errors::InvalidHash => e
    false
  end

  def member_of_admins?
    !groups.find_by_name('Admins').blank?
  end

  def self.no_admin_yet?
    find_by_is_admin(true).blank?
  end

  private

  def create_root_folder_and_admins_group
    Folder.create(:name => 'Root Folder')
    Folder.root.children.create(:name => 'Web Index')
    groups << Group.create(:name => 'Admins')
  end
  
  def create_personnal_and_scan_folders
  	self.private_folder = Folder.root.children.create(:name => name+"'s Documents", :private => true)
    self.scans_folder = Folder.root.children.create(:name => name+"'s Scans", :private => true)
    save(:validate => false)
  end

  def create_admin_permissions
    Folder.all.each do |folder|
      UserFolderPermission.create! do |p|
        p.user = self
        p.folder = folder
        p.can_create = true
        p.can_read = true
        p.can_update = true
        p.can_delete = true
      end
    end
  end

  def create_permissions
    Folder.all.each do |folder|
      UserFolderPermission.create! do |p|
        p.user = self
        p.folder = folder
        p.can_create = folder == self.private_folder || folder == self.scans_folder 
        p.can_read = folder.is_root? || folder == self.private_folder || folder == self.scans_folder  # New Users can read the root folder
        p.can_update = folder == self.private_folder || folder == self.scans_folder 
        p.can_delete = false 
      end
    end
  end

  def dont_destroy_admin
    raise t(:cant_detete_super_admin_user) if is_admin
  end
end
