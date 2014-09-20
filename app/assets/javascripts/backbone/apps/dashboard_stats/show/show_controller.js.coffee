@Antikobpae.module "DashboardStatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      stats = App.request "stat:entities"
      
      App.execute 'when:fetched', stats, ->
        console.log "Stats", stats

      statsView = @getStatsView stats
      
      @show statsView,
        loading: true

    getStatsView: (stats) ->
      new Show.Stats
        model: stats
