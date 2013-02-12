class App.Document extends Spine.Model
  @configure 'Document', 'name', 'status', 'content', 'words_length', 'chars_length', 'attachment_file_type', 'attachment_file_name', 'attachment_content_type', 'attachment_file_size', 'attachment_updated_at', 'from', 'delta', 'text_only', 'folder_id', 'created_at', 'updated_at'
  @belongsTo 'folder', 'App.Folder'
  @extend Spine.Model.Ajax

  resourceUrl: ->
	"/folders/#{@folder_id}/documents"