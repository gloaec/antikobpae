class Group < ActiveRecord::Base
  has_many :group_folder_permissions, :dependent => :destroy
  has_and_belongs_to_many :users

  validates_uniqueness_of :name
  validates_presence_of :name

  after_create :create_admin_permissions, :if => :admins_group?
  after_create :create_permissions, :unless => :admins_group?
  before_destroy :dont_destroy_admins

  def admins_group?
    name == 'Admins'
  end

  %w{create read update delete}.each do |method|
  	define_method "can_user_#{method}" do |folder|
  	  has_permission = false
  	  unless group.group_folder_permissions.send("find_by_folder_id_and_can_#{method}", folder.id, true).blank?
  	      has_permission = true
  	  end
  	  has_permission
  	end
  	#define_method "can_user_#{method}_scan" do |scan|
  	#  send "can_user_#{method}", scan.folder
  	#end
  end

  private

  def create_admin_permissions
    Folder.all.each do |folder|
      GroupFolderPermission.create! do |p|
        p.group = self
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
      GroupFolderPermission.create! do |p|
        p.group = self
        p.folder = folder
        p.can_create = false
        p.can_read = folder.is_root? # New groups can read the root folder
        p.can_update = false
        p.can_delete = false
      end
    end
  end

  def dont_destroy_admins
    raise "Can't delete admins group" if admins_group?
  end
end
