@Antikobpae.module "CoreApp", (CoreApp, App, Backbone, Marionette, $, _) ->

  class CoreApp.Router extends Marionette.AppRouter
    appRoutes:
      "*404": "not_found"
    
  API =
    not_found: ->
      new CoreApp.NotFound.Controller
      
  App.addInitializer ->
    new CoreApp.Router
      controller: API
  
