@Antikobpae.module "SidebarApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      sidebarView = @getSidebarView()

      sidebarView.on "sidebar:rendered", ->
        App.vent.trigger "sidebar:rendered"

      @show sidebarView

    getSidebarView: () ->
      new List.Sidebar()
