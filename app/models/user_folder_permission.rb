class UserFolderPermission < ActiveRecord::Base
  belongs_to :folder
  belongs_to :user
end
