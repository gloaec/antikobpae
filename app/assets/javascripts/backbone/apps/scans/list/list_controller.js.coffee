@Antikobpae.module "ScansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      scans = App.request "scan:entities"
      # TODO Get the lastest one that hasn't stated yet as new

      App.execute 'breadcrumbs',
        name: 'My Scans'
        icon: 'bar-chart-o'

      scansView = @getScansView scans

      @show scansView,
        loading: true,
        page:
          title: "My Scans"
          subtitle: "Lastest scans results"
          breadcrumb:
            name: "My Scans"
            icon: "bar-chart-o"

    getScansView: (scans) ->
      new List.Scans
        collection: scans
