@Antikobpae.module "ScansApp", (ScansApp, App, Backbone, Marionette, $, _) ->

  class ScansApp.Router extends Marionette.AppRouter
    appRoutes:
      "scans"    : "list"
      "scans/new": "new"
    
  API =
    list: ->
      new ScansApp.List.Controller
    new: ->
      new ScansApp.New.Controller
      
  App.addInitializer ->
    new ScansApp.Router
      controller: API
