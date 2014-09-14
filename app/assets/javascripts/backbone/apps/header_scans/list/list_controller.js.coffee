@Antikobpae.module "HeaderScansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      scans = App.request "header:scan:entities"
      
      scansView = @getScansView scans
      
      @show scansView,
        loading: true

    getScansView: (scans) ->
      new List.Scans
        collection: scans
