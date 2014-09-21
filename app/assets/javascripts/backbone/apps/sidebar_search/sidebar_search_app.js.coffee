@Antikobpae.module "SidebarSearchApp", (SidebarSearchApp, App, Backbone, Marionette, $, _) ->
    
  API =
    list: (region) ->
      new SidebarSearchApp.List.Controller
        region: region
  
  App.commands.setHandler "list:sidebar:search", (region) ->
    API.list region
