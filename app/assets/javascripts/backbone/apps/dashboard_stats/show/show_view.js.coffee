@Antikobpae.module "DashboardStatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Stats extends App.Views.ItemView
    template: "dashboard_stats/show/stats"

    initialize: ->
      setTimeout =>
        console.debug @model.get('documents')
      , 2000
    
    modelEvents:
      'change': 'render'
