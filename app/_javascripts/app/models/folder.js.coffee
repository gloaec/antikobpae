class App.Folder extends Spine.Model
  @configure 'Folder', 'name', 'private', 'parent_id', 'created_at', 'updated_at'
  @hasMany 'documents', 'App.Document'
  @hasMany 'children', 'App.Folder'
  @belongsTo 'folder', 'App.Folder'
  @extend Spine.Model.Ajax