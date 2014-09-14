@Antikobpae.module "Components.Flash", (Flash, App, Backbone, Marionette, $, _) ->
	
  class Flash.FlashController extends App.Controllers.Base

    initialize: (options) ->

      @flashes = options.flashes or= App.request "flash:entities"
      @region = options.region or= App.flashRegion

    add: (options) ->
      _.defaults options,
        message: "Hello World"
        className: "alert-info"

      {message, className} = options
      className = "alert alert-dismissable #{className}"

      @flashes.add
        message: message
        className: className

    showMessages: ->
      flashesView =  @getFlashesView @flashes
      @show flashesView
      flashesView.stopListening()
      @flashes.reset()

    getFlashesView: (flashes) ->
      new Flash.FlashesView
        collection: flashes

  App.addInitializer ->
    @flashController = new Flash.FlashController

  Backbone.history.on 'navigate', ->
    App.flashController.showMessages()

  App.commands.setHandler "flash:info", (message) ->
    App.flashController.add
      message   : message
      className : 'alert-info'

  App.commands.setHandler "flash:error", (message) ->
    App.flashController.add
      message   : message
      className : 'alert-danger'

  App.commands.setHandler "flash:warning", (message) ->
    App.flashController.add
      message   : message
      className : 'alert-warning'

  App.commands.setHandler "flash:success", (message) ->
    App.flashController.add
      message   : message
      className : 'alert-success'

