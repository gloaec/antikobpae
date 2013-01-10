class Image < ActiveRecord::Base
  belongs_to :document
  has_attached_file :attachment,
    :styles => {
      :large => "800x600>",
      :thumb => "100x100#" }
    #:url => ""
    #:path => "#{AppConfig.storage_path}/:rails_env/:document_id/:style/:document_id/images/:id"
  
  
  validates_attachment_presence :attachment, :message => I18n.t(:blank, :scope => [:activerecord, :errors, :messages])
end
