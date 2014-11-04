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

    ui:
      preview: '#preview'

    bindings:
      '.name'                 : 'name'
      '.attachment_file_name' : 'attachment_file_name'
      
    onRender: ->
      @stickit()
      #if @model.get 'attachment_file_type' == 'pdf'
      PDFJS.getDocument("/documents/#{@model.id}.pdf").then (pdf) ->
        pdf.getPage(2).then (page) ->
          scale = 1.5
          viewport = page.getViewport(scale)
          canvas = document.getElementById('preview')
          context = canvas.getContext('2d')
          canvas.height = viewport.height
          canvas.width = viewport.width
          renderContext =
            canvasContext: context
            viewport: viewport
          page.render(renderContext)
