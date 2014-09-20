@Antikobpae.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()

      App.execute 'breadcrumbs', false

      @listenTo @layout, "show", =>
        @listScans()
        @listDocuments()
        @showStats()

      @show @layout
    
    listScans: ->
      App.execute "list:dashboard:scans", @layout.scansRegion
    
    listDocuments: ->
      App.execute "list:dashboard:documents", @layout.documentsRegion

    showStats: ->
      App.execute "show:dashboard:stats", @layout.statsRegion

    getLayoutView: ->
      new Show.Layout
