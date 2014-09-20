@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Stats extends Entities.Model

  API =
    getStats: (url, params = {}) ->
      _.defaults params, {}
      
      stats = new Entities.Stats
      stats.url = "/#{url}.json"
      stats.fetch
        reset: true
      stats
    
  App.reqres.setHandler "stat:entities", ->
    API.getStats "stats"
