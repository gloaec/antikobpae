ThinkingSphinx::Index.define :metadata, :with => :active_record, :delta => true do
  indexes value
  has document_id
  set_property :delta => :delayed
  #has created_at, updated_at
end