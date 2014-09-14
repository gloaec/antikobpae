@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Button extends Entities.Model

  class Entities.ButtonsCollection extends Entities.Collection
    model: Entities.Button

  API =
    getButtons: ->
      new Entities.FlashesCollection

  App.reqres.setHandler "button:entities", ->
    API.getButtons()
