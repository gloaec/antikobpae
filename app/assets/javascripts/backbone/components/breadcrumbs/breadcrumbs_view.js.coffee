@Antikobpae.module "Components.Breadcrumbs", (Breadcrumbs, App, Backbone, Marionette, $, _) ->

  class Breadcrumbs.BreadcrumbView extends App.Views.ItemView
    template: "breadcrumbs/_breadcrumb"
    tagName: 'li'

    modelEvents:
      'change': 'render'

    attributes: ->
      class: 'active' if @model.get('leaf')

    bindings:
      '.name':'name'

    onRender: ->
      @stickit()

  class Breadcrumbs.BreadcrumbsView extends App.Views.CollectionView
    itemView  : Breadcrumbs.BreadcrumbView
    tagName   : "ul"
    className : "breadcrumb page-breadcrumb"

