@Antikobpae.module "DashboardStatsApp", (DashboardStatsApp, App, Backbone, Marionette, $, _) ->

  API =
    show: (region) ->
      new DashboardStatsApp.Show.Controller
        region: region
  
  App.commands.setHandler "show:dashboard:stats", (region) ->
    API.show region
