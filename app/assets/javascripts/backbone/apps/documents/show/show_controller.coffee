@Antikobpae.module "DocumentsApp.Show", (Show, App, Backbone, Marionette) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->

      if options.document
        document = options.document
        document.fetch()
      else
        document = App.request "document:entity", options.id

      documentView = @getDocumentView document

      @show documentView,
        loading: true
        page:
          breadcrumb: document
          title: 'Loading...'
          title_attribute: 'name'

    getDocumentView: (document) ->
      new Show.Document
        model: document
