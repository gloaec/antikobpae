@Antikobpae.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @listScans()

      @show @layout
    
    listScans: ->
      @layout.on "show:scans:clicked", =>
        setTimeout =>
          App.execute "list:header:scans", @layout.headerScansRegion
        , 1#ms  Delay on click not to interfer with bootstrap

    getLayoutView: ->
      new List.Layout
