@Antikobpae.module "DocumentsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Document extends App.Views.ItemView
    template: "documents/show/document"
 
    bindings:
      '.name'                 : 'name'
      '.attachment_file_name' : 'attachment_file_name'
      
    onRender: ->
      @stickit()
