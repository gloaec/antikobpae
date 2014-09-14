@Antikobpae.module "FoldersApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->
      folders = options.folders or= App.request "folder:entities"
      console.log folders
      folder = new folders.model()

      @newView = @getNewView folder, folders
			
      @listenTo @newView, "form:submitted", =>
        #data = Backbone.Syphon.serialize newView
        #post.processForm data, posts
			
      @show @newView

    getNewView: (folder, folders) ->
      new New.Folder
        model      : folder
        collection : folders
