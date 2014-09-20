@Antikobpae.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "header/list/list_layout"

    regions:
      headerScansRegion: Marionette.Region.Nowrap.extend el: "#header-scans-region"
      sidebarRegion:     "#sidebar-region"

    events:
      "click a[href=#header-scans-region]" : -> @trigger 'show:scans:clicked', @model
