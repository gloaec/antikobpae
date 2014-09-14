@Antikobpae.module "FolderDocumentsApp", (FolderDocumentsApp, App, Backbone, Marionette, $, _) ->

  class FolderDocumentsApp.Router extends Marionette.SubRouter

    prefix: "folders/:folder_id/documents"

    appRoutes:
      "new"         : "new"
      "new/:type"   : "new"
    
  API =
    new: (folder_id, type='document', folder=false) ->
      new FolderDocumentsApp.New.Controller
        folder_id : folder_id,
        type      : type
        folder    : folder

  App.vent.on "new:folder:document:clicked", (folder) ->
    App.navigate "folders/#{folder.id}/documents/new"
    API.new folder.id, 'document', folder

  App.vent.on "new:folder:webpage:clicked", (folder) ->
    App.navigate "folders/#{folder.id}/documents/new/webpage"
    API.new folder.id, 'webpage', folder

  App.addInitializer ->
    new FolderDocumentsApp.Router
      controller: API
