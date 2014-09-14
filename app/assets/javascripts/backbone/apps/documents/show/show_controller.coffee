@Antikobpae.module "DocumentsApp.Show", (Show, App, Backbone, Marionette) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->
      document = options.document #or= 
      document = App.request "document:entity", options.id
  
      #App.execute 'breadcrumbs', document
      
      documentView = @getDocumentView document

      @show documentView,
        loading: true
        page:
          breadcrumb: document

    getDocumentView: (document) ->
      new Show.Document
        model: document
