@Antikobpae.module "SidebarApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()

      @layout.on "sidebar:rendered", ->
        App.vent.trigger "sidebar:rendered"

      @listenTo @layout, "show", =>
        @listSearch()

      @show @layout
    
    listSearch: ->
      App.execute "list:sidebar:search", @layout.searchRegion
    
    getLayoutView: ->
      new Show.Layout
