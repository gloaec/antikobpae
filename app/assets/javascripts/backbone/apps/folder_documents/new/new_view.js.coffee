@Antikobpae.module "FolderDocumentsApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Webpage extends App.Views.ItemView
    template: "folder_documents/new/new_webpage"

    initialize: ->
      @listenTo @model, 'validated', (_, __, attrs) => @showErrors(attrs)

    ui:
      "attachment_file_name" : ".attachment_file_name"
      "preview"              : "#preview"

    events:
      'submit form' : 'formSubmitted'

    modelEvents:
      'change attachment_file_name': ->
        @model.set name: @model.get('attachment_file_name')
        @ui.preview.attr src: @model.get('attachment_file_name')

    bindings:
      ".attachment_file_name" : "attachment_file_name"
      ".name"                 : "attachment_file_name"

    onRender: ->
      @stickit()
      @ui.preview.on 'load', =>

    formSubmitted: (e) ->
      e.preventDefault()
      console.log @model.toJSON()
      @model.save from: 'webpage',
        success: =>
          @collection.add @model
          App.execute "flash:success", "Webpage ##{@model.id} successfully imported"
          App.navigate @model.get('folder').url(), trigger: true
        error: (post, jqXHR) =>
          @showErrors $.parseJSON(jqXHR.responseText).errors


  class New.Document extends App.Views.ItemView
    template: "folder_documents/new/new_document"

    initialize: ->
      @listenTo @model, 'validated', (_, __, attrs) => @showErrors(attrs)

    ui:
      "name"       : "#name"
      "content"    : "#content"

    events:
      'submit form' : 'formSubmitted'

    bindings:
      "#name"      : "name"
      "#content"   : "content"

    onRender: ->
      _.defer => @ui.content.ckeditor height: 350
      @stickit()
      @validateit()

    formSubmitted: (e) ->
      e.preventDefault()
      @model.set content: @ui.content.val().trim()
      console.log @model.toJSON()
      if @model.isValid(true)
        @model.save from: 'scratch',
          success: =>
            @collection.add @model
            App.execute "flash:success", "Document ##{@model.id} successfully created"
            App.navigate @model.get('folder').url(), trigger: true
          error: (post, jqXHR) =>
            @showErrors $.parseJSON(jqXHR.responseText).errors

