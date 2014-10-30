@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Breadcrumb extends Entities.Model
    defaults:
      name: "New"
      leaf: false
      root: false
      url: "/"

    url: "/"
      
  class Entities.BreadcrumbsCollection extends Entities.Collection
    model: Entities.Breadcrumb

  API =
    getBreadcrumbs: ->
      new Entities.BreadcrumbsCollection

    getBreadcrumb: ->
      new Entities.Breadcrumb

  App.reqres.setHandler "breadcrumb:entities", ->
    API.getBreadcrumbs()
    
  App.reqres.setHandler "breadcrumb:entity", ->
    API.getBreadcrumb()
