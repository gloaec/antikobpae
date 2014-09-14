@Antikobpae.module "DocumentsApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->
      console.log 'options', options
      {document, documents} = options

      @newDocumentView = @getNewDocumentView document, documents
			
      @listenTo @newDocumentView, "form:submitted", =>
        #data = Backbone.Syphon.serialize newView
        #post.processForm data, posts
			
      @show @newDocumentView

    getNewDocumentView: (document, documents) ->
      new New.Document
        model      : document
        collection : documents

