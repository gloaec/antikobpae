@Antikobpae.module "FoldersApp.Show", (Show, App, Backbone, Marionette) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->

      if options.folder
        folder = options.folder
        folder.fetch()
      else
        folder = App.request "folder:entity", options.id
      files = App.request "folder:file:entities", folder
      
      @layout = @getLayoutView()
      
      @listenTo @layout, "show", =>
        @folderView folder, files
        @filesView folder, files

      @show @layout,
        loading:
          entities: folder
        page:
          title: 'Loading'
          breadcrumb: folder
          toolbar:
            view: @toolbarView folder, files

    folderView: (folder, files) ->
      folderView = @getFolderView folder, files

      folderView.on "new:folder:document:clicked", (folder) ->
        App.vent.trigger "new:folder:document:clicked", folder

      folderView.on "new:folder:upload:clicked", (folder) ->
        App.vent.trigger "new:folder:upload:clicked", folder

      @show folderView, region: @layout.folderRegion

    filesView: (folder, files) ->
      filesView = App.execute "list:folder:files",
        folder: folder
        files:  files
        region: @layout.filesRegion

    toolbarView: (folder, files) ->
      toolbarView = @getToolbarView folder, files
      toolbarView

    getFolderView: (folder, files) ->
      new Show.Folder
        model: folder
        collection: files

    getToolbarView: (folder, files) ->
      new Show.Toolbar
        model: folder
        collection: files

    getLayoutView: ->
      new Show.Layout
