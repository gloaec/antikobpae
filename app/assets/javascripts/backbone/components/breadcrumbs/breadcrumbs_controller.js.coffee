@Antikobpae.module "Components.Breadcrumbs", (Breadcrumbs, App, Backbone, Marionette, $, _) ->
	
  class Breadcrumbs.BreadcrumbsController extends App.Controllers.Base

    initialize: (options) ->
	    #Backbone.history.on 'route', @updateBreadcrumbs

      @breadcrumbs = options.breadcrumbs or= App.request "breadcrumb:entities"
      @breadcrumb = options.breadcrumb# or= new @breadcrumbs.model
      @region = options.region or= App.request "default:breadcrumbs:region"


      if @breadcrumb instanceof App.Entities.Model
        App.execute "when:fetched", @breadcrumb, =>
          @generateBreadcrumbs @breadcrumb
      else
        @generateBreadcrumbs @breadcrumb

      console.log 'options', @breadcrumbs
      breadcrumbsView =  @getBreadcrumbsView @breadcrumbs
      @show breadcrumbsView

    getBreadcrumbsView: (breadcrumbs) ->
      new Breadcrumbs.BreadcrumbsView
        collection: breadcrumbs
 
    updateBreadcrumbs: ->
    # Manage @crumbs here.

    generateBreadcrumbs: (entity) ->
      leaf = if entity instanceof App.Entities.Model
      then entity
      else new @breadcrumbs.model
      leaf.set leaf: true
      root = new @breadcrumbs.model
        root: true
        name: 'Dashboard'
        icon: 'dashboard'
      if entity instanceof App.Entities.Folder
        leaf.set parent: entity.get('parent')
        leaf.set name:   entity.get('name')
        if entity == App.current_user.get('scans_folder')
          leaf.set icon: 'tasks'
        else
          leaf.set icon: 'folder-open'
        leaf.set url:    entity.url()
      else if entity instanceof App.Entities.Document
        leaf.set parent: entity.get('folder')
        leaf.set name:   entity.get('name')
        leaf.set icon:   entity.icon()
        leaf.set url:    entity.url()
      else if entity instanceof App.Entities.Scan
        leaf.set parent: entity.get('folder')
        leaf.set name:   entity.get('name')
        leaf.set icon:   'bar-chart-o'
        leaf.set url:    entity.url()
      else if _.isObject(entity)
        leaf.set parent: root
        leaf.set entity
      else return @breadcrumbs.reset()
      @breadcrumbs.reset @recBreadcrumbs(leaf.get('parent')).concat [leaf]
      
    recBreadcrumbs: (folder) ->
      return [] unless folder
      breadcrumb = new @breadcrumbs.model
      if folder.get('parent')
        breadcrumb.set parent: folder.get('parent')
        breadcrumb.set name:   folder.get('name')
        if folder == App.current_user.get('scans_folder')
          breadcrumb.set url:  "/scans"
          breadcrumb.set icon: 'tasks'
        else
          breadcrumb.set url:  folder.url()
          breadcrumb.set icon: 'folder-open'
      else
        breadcrumb.set name:   'Dashboard'
        breadcrumb.set icon:   'dashboard'
        breadcrumb.set url:    '/dashboard'
      @recBreadcrumbs(folder.get('parent')).concat [breadcrumb]

  App.addInitializer ->
    @breadcrumbsController = new Breadcrumbs.BreadcrumbsController

  App.commands.setHandler "breadcrumbs", (entity) ->
    if entity instanceof App.Entities.Model
      App.execute "when:fetched", entity, =>
        App.breadcrumbsController.generateBreadcrumbs entity
    else
      App.breadcrumbsController.generateBreadcrumbs entity

  App.commands.setHandler "show:breadcrumbs", (options) ->
    new Breadcrumbs.BreadcrumbsController options


      #Backbone.history.on 'navigate', (a,b,c,d) ->
      #  console.log 'Navigate', a, b, c, d
      #  App.breadcrumbsController.updateBreadcrumbs()

