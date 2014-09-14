@Antikobpae = do (Backbone, Marionette) ->

  console.info 'Loading application '

  App = new Marionette.Application

  App.addRegions
    headerRegion:       "#header-region"
    sidebarRegion:      "#sidebar-region"
    mainRegion:         "#main-region"
    footerRegion:       "#footer-region"
    flashRegion:        Marionette.Region.Flashes.extend el: "#flash-region"
    breadcrumbsRegion:  Marionette.Region.Breadcrumbs.extend el: "#breadcrumbs-region"
    dialogRegion:       Marionette.Region.Dialog.extend el: "#dialog-region"
  
  App.rootRoute = "/dashboard"

  App.reqres.setHandler "default:region", ->
    App.mainRegion
  App.reqres.setHandler "default:flash:region", ->
    App.flashRegion
  App.reqres.setHandler "default:breadcrumbs:region", ->
    App.breadcrumbsRegion
  App.reqres.setHandler "default:dialog:region", ->
    App.dialogRegion

  App.addInitializer ->
    App.module("HeaderApp").start()
    App.module("SidebarApp").start()
    App.module("FooterApp").start()
  
  App.commands.setHandler "register:instance", (instance, id) ->
    App.register instance, id
  
  App.commands.setHandler "unregister:instance", (instance, id) ->
    App.unregister instance, id

  App.on "initialize:after", (options) ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App
