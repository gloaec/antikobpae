@Antikobpae.module "FolderFilesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: (options) ->
      {folder, files, region} = options
      console.debug (options)
      folder or= App.request "folder:entity", options.id
      files or= App.request "folder:file:entities", folder

      filesView = @getFilesView files

      filesView.on "childview:file:clicked", (iv, file, type) ->
        App.vent.trigger "#{type}:clicked", file

      filesView.on "childview:edit:file:clicked", (iv, file, type) ->
        App.vent.trigger "edit:#{type}:clicked", file

      filesView.on "childview:delete:file:clicked", (iv, file, type) ->
        App.vent.trigger "delete:#{type}:clicked", file
      
      @show filesView,
        loading:
          entities: folder
        region: region

    getFilesView: (files) ->
      new List.Files
        collection: files
