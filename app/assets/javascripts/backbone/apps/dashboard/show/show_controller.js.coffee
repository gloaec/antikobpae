@Antikobpae.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()

      App.execute 'breadcrumbs', false

      @listenTo @layout, "show", =>
        @listUpcoming()
        @listTheatre()

      @show @layout
    
    listUpcoming: ->
      App.execute "list:dashboard:scans", @layout.scansRegion
    
    listTheatre: ->
      App.execute "list:dashboard:documents", @layout.documentsRegion

    getLayoutView: ->
      new Show.Layout
