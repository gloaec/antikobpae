@Antikobpae.module "DashboardDocumentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      documents = App.request "latest:document:entities"
      
      documentsView = @getDocumentsView documents
      
      @show documentsView,
        loading: true

    getDocumentsView: (documents) ->
      new List.Documents
        collection: documents
