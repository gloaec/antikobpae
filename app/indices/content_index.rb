ThinkingSphinx::Index.define :content, :with => :active_record, :delta => true do
  indexes text
  indexes document(:name),:as => :name#, :sortable => true
  indexes document(:attachment_file_name),:as => :file_name#, :sortable => true
  has document_id
  set_property :delta => :delayed
  #has created_at, updated_at
end