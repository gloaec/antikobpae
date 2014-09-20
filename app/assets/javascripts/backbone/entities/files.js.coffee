@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.File extends Entities.Model

  class Entities.FilesCollection extends Entities.Collection

    model: Entities.File

    initialize: (models, options) ->
      @options = options || {}

    url: ->
      if @options.folder?.id?
        "/folders/#{@options.folder.id}/files"
      else
        "/files"

    import: (models, type) ->
      models = models.models if models instanceof Entities.Collection
      if _.isArray models
        for model in models
          _type = type or=
            if model instanceof Entities.Document then 'document'
            else if model instanceof Entities.Folder then '_folder'
            else if model instanceof Entities.Scan then 'scan'
            else 'file'
          #file = _.extend model.toJSON(), type: _type
          model.set type: _type
          @add model

    comparator: (m) ->
      -m.get "created_at"

    getDocuments: ->
      new Entities.FilesCollection @where type: 'document'

    getPendingDocuments: ->
      new Entities.FilesCollection @getDocuments().filter (document) ->
        document.get('status') < 3

    fetchPendingDocuments: ->
      @fetch
        url: "/documents/#{@getPendingDocuments().pluck('id').join(';')}"

    getFolders: ->
      @where type: '_folder'


  API =
    getFolderFiles: (folder) ->
      files = new Entities.FilesCollection [], folder: folder
      files.import folder.get('children'), '_folder'
      files.import folder.get('documents'), 'document'
      files
      
    
  App.reqres.setHandler "folder:file:entities", (folder) ->
    API.getFolderFiles folder
