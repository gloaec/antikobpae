@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Author extends Entities.Model
    @mixin Entities.User

    relations: [
      type: Backbone.Many
      key: 'folders'
      relatedModel: 'Antikobpae.Entities.Folder'
    ]

    defaults:
      folders: []

  class Entities.Folder extends Entities.Model

	  #set: (key, value, options) ->
    	  #  ret = Entities.Model::set.apply @, arguments
    	  #  @get('documents').options.folder_id = @id
    	  #  ret
      
    urlRoot: -> "/folders"

    relations: [
      type: Backbone.One
      key: 'parent'
      relatedModel: Backbone.Self
    ,
      type: Backbone.Many
      key: 'documents'
      collectionType: 'Antikobpae.Entities.DocumentsCollection'
    ,
      type: Backbone.Many
      key: 'children'
      collectionType: 'Antikobpae.Entities.FoldersCollection'
    ]

    defaults:
      author: null

    validation:
      title: [
        required: true
        msg: 'Title is required'
      ,
        pattern: /^[A-Z]/
        msg: 'Must start with capital letter'
      ]
      content:
        maxLength: 140
        msg: 'Folder is too long (140 chars maximum)'

    icon: -> 'folder'
    
  class Entities.FoldersCollection extends Entities.Collection

    model: Entities.Folder

    url: -> "/folders"

    comparator: (m) ->
      -m.get "created_at"

    getByAuthorID: (id) ->
      @where author_id: id
	

  API =
    getFolders: () ->
      folders = new Entities.FoldersCollection
      folders.fetch reset: true
      folders

    getFolder: (id) ->
      folder = new Entities.Folder id: id
      folder.fetch()
      folder

    getFolderDocuments: (folder) ->
      folder.get('documents').fetch()
      folder.get('documents')


  App.reqres.setHandler "folder:entities", ->
    API.getFolders()
    
  App.reqres.setHandler "folder:entity", (id) ->
    API.getFolder id

  App.reqres.setHandler "folder:document:entities", (folder) ->
    API.getFolderDocuments folder
