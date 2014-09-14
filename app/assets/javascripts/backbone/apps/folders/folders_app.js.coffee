@Antikobpae.module "FoldersApp", (FoldersApp, App, Backbone, Marionette, $, _) ->

  class FoldersApp.Router extends Marionette.SubRouter

    prefix: "folders"

    appRoutes:
      "new"      : "new"
      ":id"      : "show"
      ":id/edit" : "edit"

  API =
    new: (folders=false) ->
      new FoldersApp.New.Controller folders: folders

    show: (id, folder=false) ->
      new FoldersApp.Show.Controller id: id, folder: folder

    edit: (id, folder=false) ->
      new FoldersApp.Edit.Controller id: id, folder: folder

    delete: (id, folder=false) ->
      folder.destroy()

  App.vent.on "folder:clicked", (folder) ->
    App.navigate "folders/#{folder.id}"
    API.show folder.id, folder

  App.vent.on "new:folder:clicked", (folders) ->
    App.navigate "folders/new"
    API.new folders

  App.vent.on "edit:folder:clicked", (folder) ->
    App.navigate "folders/#{folder.id}/edit"
    API.edit folder.id, folder

  App.vent.on "delete:folder:clicked", (folder) ->
    App.navigate "folders/#{folder.id}/delete"
    API.delete folder.id, folder

  App.addInitializer ->
    new FoldersApp.Router
      controller: API
