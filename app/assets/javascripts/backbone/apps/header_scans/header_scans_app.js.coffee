@Antikobpae.module "HeaderScansApp", (HeaderScansApp, App, Backbone, Marionette, $, _) ->
    
  API =
    list: (region) ->
      new HeaderScansApp.List.Controller
        region: region
  
  App.commands.setHandler "list:header:scans", (region) ->
    API.list region
