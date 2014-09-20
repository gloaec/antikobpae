@Antikobpae.module "Components.Toolbar", (Toolbar, App, Backbone, Marionette, $, _) ->
	
  class Toolbar.ToolbarController extends App.Controllers.Base

    initialize: (options) ->
      @menu = options.menu# or= new @toolbar.model
      @region = options.region or= App.request "default:toolbar:region"

      if @menu instanceof App.Entities.Model
        App.execute "when:fetched", @menu, =>
        
      toolbarView = options.toolbar?.view or= @getToolbarView @menu
      @show toolbarView

    getToolbarView: (toolbar) ->
      new Toolbar.ToolbarView
        collection: toolbar
 

  App.commands.setHandler "show:toolbar", (options) ->
    new Toolbar.ToolbarController options
