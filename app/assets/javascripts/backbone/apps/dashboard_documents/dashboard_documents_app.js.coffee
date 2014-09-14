@Antikobpae.module "DashboardDocumentsApp", (DashboardDocumentsApp, App, Backbone, Marionette, $, _) ->

  API =
    list: (region) ->
      new DashboardDocumentsApp.List.Controller
        region: region
  
  App.commands.setHandler "list:dashboard:documents", (region) ->
    API.list region
