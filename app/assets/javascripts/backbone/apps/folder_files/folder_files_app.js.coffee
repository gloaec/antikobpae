@Antikobpae.module "FolderFilesApp", (FolderFilesApp, App, Backbone, Marionette, $, _) ->

  API =
    list: (options) ->
      new FolderFilesApp.List.Controller options
  
  App.commands.setHandler "list:folder:files", (options) ->
    API.list options
