@Antikobpae.module "FolderDocumentsApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Toolbar extends App.Views.ItemView
    template: "folder_documents/new/_toolbar"

    events:
      "click .create-folder-document"   : -> @trigger "create:folder:document:clicked", @model

  class New.Webpage extends App.Views.ItemView
    template: "folder_documents/new/new_webpage"

    initialize: ->
      @listenTo @model, 'validated', (_, __, attrs) => @showErrors(attrs)
      @listenTo @, 'create:folder:document:clicked', @createFolderDocumentClicked

    ui:
      form                 : "form"
      attachment_file_name : ".attachment_file_name"
      preview              : "#preview"

    events:
      'submit form' : 'formSubmitted'

    modelEvents:
      'change:name': ->
        @model.set attachment_file_name: @model.get('name')
        @ui.preview.attr src: @model.get('name')

    bindings:
      ".attachment_file_name" : "attachment_file_name"
      ".attachment_file_name" : "name"

    onRender: ->
      @stickit()
      @validateit()
      @ui.preview.on 'load', =>

    createFolderDocumentClicked: (document) ->
      @ui.form.submit()

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
      @listenTo @, 'create:folder:document:clicked', @createFolderDocumentClicked

    ui:
      name       : "#name"
      content    : "#content"
      form       : "form"

    events:
      'submit form' : 'formSubmitted'

    bindings:
      "#name"      : "name"
      "#content"   : "content"

    onRender: ->
      _.defer => @ui.content.ckeditor height: 350
      @stickit()
      @validateit()

    createFolderDocumentClicked: (document) ->
      @ui.form.submit()

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

