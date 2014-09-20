@Antikobpae.module "ScansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      scans = App.request "scan:entities"
      # TODO Get the lastest one that hasn't stated yet as new

      scansView = @getScansView scans

      @show scansView,
        loading: true,
        page:
          title: "My Scans"
          subtitle: "Lastest scans results"
          breadcrumb: App.current_user.get('scans_folder')
          toolbar:
            view: @toolbarView scans

    toolbarView: (scans) ->
      toolbarView = @getToolbarView scans
      toolbarView

    getToolbarView: (scans) ->
      new List.Toolbar
        model: scans

    getScansView: (scans) ->
      new List.Scans
        collection: scans
