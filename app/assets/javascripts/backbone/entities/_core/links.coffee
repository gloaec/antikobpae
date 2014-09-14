@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Link extends Entities.Model

  class Entities.LinksCollection extends Entities.Collection
    model: Entities.Link

  API =
    getLinks: ->
      new Entities.FlashesCollection

  App.reqres.setHandler "link:entities", ->
    API.getLinks()
