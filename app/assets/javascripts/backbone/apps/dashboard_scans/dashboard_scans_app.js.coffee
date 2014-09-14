@Antikobpae.module "DashboardScansApp", (DashboardScansApp, App, Backbone, Marionette, $, _) ->
    
  API =
    list: (region) ->
      new DashboardScansApp.List.Controller
        region: region
  
  App.commands.setHandler "list:dashboard:scans", (region) ->
    API.list region
