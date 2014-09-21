@Antikobpae.module "SidebarApp", (SidebarApp, App, Backbone, Marionette, $, _) ->
    
  API =
    show: () ->
      new SidebarApp.Show.Controller
        region: App.sidebarRegion

  SidebarApp.on "start", ->
    API.show()
