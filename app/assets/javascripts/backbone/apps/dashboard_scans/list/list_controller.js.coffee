@Antikobpae.module "DashboardScansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      scans = App.request "dashboard:scan:entities"

      scansView = @getScansView scans

      @show scansView,
        loading: true,
        region: @region

    getScansView: (scans) ->
      new List.Scans
        collection: scans
