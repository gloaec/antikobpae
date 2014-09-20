@Antikobpae.module "DashboardApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "dashboard/show/show_layout"

    regions:
      scansRegion:     "#dashboard-scans-region"
      documentsRegion: "#dashboard-documents-region"
      statsRegion:    "#dashboard-stats-region"
