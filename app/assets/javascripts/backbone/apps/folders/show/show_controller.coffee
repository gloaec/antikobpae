@Antikobpae.module "FoldersApp.Show", (Show, App, Backbone, Marionette) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->

      if options.foler
        folder = options.folder
        folder.fetch()
      else
        folder = App.request "folder:entity", options.id
      
      @layout = @getLayoutView()
      
      @listenTo @layout, "show", =>
        @folderView folder
        @filesView folder

      @show @layout,
        loading:
          entities: folder
        page:
          title: 'Loading'
          breadcrumb: folder

    folderView: (folder) ->
      folderView = @getFolderView folder

      folderView.on "new:folder:document:clicked", (folder) ->
        App.vent.trigger "new:folder:document:clicked", folder

      folderView.on "new:folder:upload:clicked", (folder) ->
        App.vent.trigger "new:folder:upload:clicked", folder

      @show folderView, region: @layout.folderRegion

    filesView: (folder) ->
      filesView = App.execute "list:folder:files",
        folder: folder
        region: @layout.filesRegion

    getFolderView: (folder) ->
      new Show.Folder
        model: folder

    getLayoutView: ->
      new Show.Layout
