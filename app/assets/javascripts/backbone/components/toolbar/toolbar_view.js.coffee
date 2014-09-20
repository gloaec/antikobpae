@Antikobpae.module "Components.Toolbar", (Toolbar, App, Backbone, Marionette, $, _) ->

  class Toolbar.MenuView extends App.Views.ItemView
    template: "toolbar/toolbar"
    tagName: 'li'

    modelEvents:
      'change': 'render'

    bindings:
      '.name':'name'

    onRender: ->
      @stickit()

  class Toolbar.ToolbarView extends App.Views.CollectionView
    itemView  : Toolbar.MenuView
    tagName   : "ul"
