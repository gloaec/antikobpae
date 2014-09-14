@Antikobpae.module "DocumentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      documents = App.request "document:entities"

      App.execute 'breadcrumbs',
        name: 'My Documents'
        icon: 'folder'

      documentsView = @getDocumentsView documents

      documentsView.on "childview:edit:document:clicked", (iv, document) ->
        App.vent.trigger "edit:document:clicked", document

      documentsView.on "childview:document:clicked", (iv, document) ->
        App.vent.trigger "document:clicked", document

      documentsView.on "childview:delete:document:clicked", (iv, document) ->
        App.vent.trigger "delete:document:clicked", document

      @show documentsView,
        loading: true

    getDocumentsView: (documents) ->
      new List.Documents
        collection: documents
