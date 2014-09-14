@Antikobpae.module "SidebarApp", (SidebarApp, App, Backbone, Marionette, $, _) ->
    
  API =
    list: () ->
      new SidebarApp.List.Controller
        region: App.sidebarRegion

  SidebarApp.on "start", ->
    API.list()
