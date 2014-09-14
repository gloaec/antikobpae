@Antikobpae.module "FolderFilesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: (options) ->
      {folder, files, region} = options
      folder or= App.request "folder:entity", options.id
      files or= App.request "folder:file:entities", folder

      filesView = @getFilesView files
      
      @show filesView,
        loading:
          entities: folder
        region: region

    getFilesView: (files) ->
      new List.Files
        collection: files
