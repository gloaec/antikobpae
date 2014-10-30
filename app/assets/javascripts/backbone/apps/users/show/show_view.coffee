@Antikobpae.module "DocumentsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Toolbar extends App.Views.ItemView
    template: "documents/show/_toolbar"
    className: "btn-group pull-right"

    ui:
      buttons: 'button'

    events: {}

    onRender: ->
      @ui.buttons.tooltip()


  class Show.Document extends App.Views.ItemView
    template: "documents/show/document"

    bindings:
      '.name'                 : 'name'
      '.attachment_file_name' : 'attachment_file_name'
      
    onRender: ->
      @stickit()
