@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Document extends Entities.Model

    urlRoot: ->
      if @isNew()
        "/folders/#{@get('folder').id}/documents"
      else
        "/documents"

    defaults: {}

    relations: [
      type: Backbone.One
      key: 'folder'
      relatedModel: 'Antikobpae.Entities.Folder'
    ]

    whitelist: ["name", "content", "attachment_file_name"]

    validation:
      name:
        required: true
        msg: 'Title is required'
      content:
        required: true
        msg: 'Document cannot be empty'

    icon: ->
      switch @get('attachment_file_type')
        when "html" then "globe"
        when "pdf" then "file-pdf-o"
        when "doc" then "file-doc-o"
        when "txt" then "file-text-o"
        else "file-o"

  class Entities.DocumentsCollection extends Entities.Collection

    model: Entities.Document

    initialize: (models, options) ->
      @options = options || {}

    url: ->
      if @options.folder_id?
        "/folders/#{@options.folder_id}/documents"
      else
        "/documents"

    comparator: (m) ->
      -m.get "created_at"

    getByAuthorID: (id) ->
      @where author_id: id


  API =
    getDocuments: (params = {}) ->
      _.defaults params, {}
      documents = new Entities.DocumentsCollection
      documents.url = "/documents"
      documents.fetch
        reset: true
        data: params
      documents

    getDocument: (id) ->
      document = new Entities.Document id: id
      document.fetch()
      document
    
  App.reqres.setHandler "document:entity", (id) ->
    API.getDocument id

  App.reqres.setHandler "document:entities", ->
    API.getDocuments()
  
  App.reqres.setHandler "latest:document:entities", ->
    API.getDocuments limit: 10
    
# Use this in your browser's console to initialize a JSONP request to see the API in action.
# $.getJSON("http://api.rottentomatoes.com/api/public/v1.0/documents.json?callback=?", {apikey: "vzjnwecqq7av3mauck2238uj", q: "shining"})
