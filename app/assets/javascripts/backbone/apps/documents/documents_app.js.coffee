@Antikobpae.module "DocumentsApp", (DocumentsApp, App, Backbone, Marionette, $, _) ->

  class DocumentsApp.Router extends Marionette.SubRouter

    prefix: "documents"

    appRoutes:
      ""         : "list"
      ":id"      : "show"
      ":id/edit" : "edit"
    
  API =
    list: (options) ->
      new DocumentsApp.List.Controller options

    show: (id, document=false) ->
      new DocumentsApp.Show.Controller id: id, document: document

    edit: (id, document=false) ->
      new DocumentsApp.Edit.Controller id: id, document: document

    delete: (id, document=false) ->
      document.destroy()
      
  App.vent.on "documents:clicked", (documents) ->
    App.navigate "documents"
    API.list documents

  App.vent.on "document:clicked", (document) ->
    App.navigate "documents/#{document.id}"
    API.show document.id, document

  App.vent.on "edit:document:clicked", (document) ->
    App.navigate "documents/#{document.id}/edit"
    API.edit document.id, document

  App.vent.on "delete:document:clicked", (document) ->
    App.navigate "documents/#{document.id}/delete"
    API.delete document.id, document

  App.addInitializer ->
    new DocumentsApp.Router
      controller: API
