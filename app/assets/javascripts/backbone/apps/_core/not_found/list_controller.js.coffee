@Antikobpae.module "CoreApp.NotFound", (NotFound, App, Backbone, Marionette, $, _) ->

  class NotFound.Controller extends App.Controllers.Base

    initialize: ->
      notFoundView = @getNotFoundView()
      @show notFoundView
    
    getNotFoundView: ->
      new NotFound.NotFound
