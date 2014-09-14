@Antikobpae.module "ScansApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->
      scans = options.scans or= App.request "scan:entities"
      console.log scans
      scan = new scans.model()

      @newView = @getNewView scan, scans
			
      @listenTo @newView, "form:submitted", =>
        #data = Backbone.Syphon.serialize newView
        #post.processForm data, posts
			
      @show @newView

    getNewView: (scan, scans) ->
      new New.Scan
        model      : scan
        collection : scans
