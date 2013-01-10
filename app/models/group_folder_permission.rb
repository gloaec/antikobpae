class GroupFolderPermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :folder
end
