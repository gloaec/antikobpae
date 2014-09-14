@Antikobpae.module "Components.Page", (Page, App, Backbone, Marionette, $, _) ->
  
  class Page.PageController extends App.Controllers.Base
    
    initialize: (options) ->
      { view, config, loading } = options
      
      config = if _.isBoolean(config) then {} else config
      
      _.defaults config,
        subtitle: ""
        breadcrumb: @getEntities(view)
        debug: false

      ## TODO sync Entities.Page(title,subtitle) with
      # Entities.Breadcrumb(name,...)

      @layout = @getLayoutView config
      
      @listenTo @layout, "show", =>
        @getBreadcrumbsView config
        @getToolbarView config
        @showRealView view, config

      @show @layout

    showRealView: (realView, config) ->
      console.log 'showRealView', realView, config
      @show realView,
        region: @layout.contentRegion
    
    getEntities: (view) ->
      ## return the entities manually set during configuration, or just pull 
      ## off the model and collection from the view (if they exist)
      _.chain(view).pick("model", "collection").toArray().compact().value()
    
    getBreadcrumbsView: (config) ->
      breadcrumbsView = App.execute "show:breadcrumbs",
        breadcrumb: config.breadcrumb
        region: @layout.breadcrumbsRegion

    getToolbarView: (config) ->
      toolbarView = App.execute "show:toolbar",
        toolbar: config.toolbar
        region: @layout.toolbarRegion

    getLayoutView: (config) ->
      new Page.LayoutView
        model: config.breadcrumb
  
  App.commands.setHandler "show:page", (view, options) ->
    new Page.PageController
      view: view
      region: options.region
      loading: options.loading
      config: options.page
