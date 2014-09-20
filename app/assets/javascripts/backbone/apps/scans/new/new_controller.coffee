@Antikobpae.module "ScansApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->
      scans = options.scans or= App.request "scan:entities"
      scan = new scans.model()

      @newView = @getNewView scan, scans
			
      @listenTo @newView, "form:submitted", =>
        #data = Backbone.Syphon.serialize newView
        #post.processForm data, posts
			
      @show @newView,
        page:
          title: "New Scan"
          title_attribute: 'name'
          breadcrumb: scan
          toolbar:
            view: @toolbarView scan

    toolbarView: (scan) ->
      toolbarView = @getToolbarView scan
      toolbarView

    getToolbarView: (scan) ->
      new New.Toolbar
        model: scan

    getNewView: (scan, scans) ->
      new New.Scan
        model      : scan
        collection : scans
