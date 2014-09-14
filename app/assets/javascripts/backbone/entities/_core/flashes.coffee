@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Flash extends Entities.Model

  class Entities.FlashesCollection extends Entities.Collection
    model: Entities.Flash

  API =
    getFlashes: ->
      new Entities.FlashesCollection

  App.reqres.setHandler "flash:entities", ->
    API.getFlashes()
