@Antikobpae.module "DocumentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Empty extends App.Views.ItemView
    template: "documents/list/_empty"

  class List.Document extends App.Views.ItemView
    template: "documents/list/_document"
    tagName: 'tr'

    initialize: ->
      @timer = setInterval =>
        @model.trigger "change:updated_at", @model
        @model.trigger "change:created_at", @model
      , 30000

    bindings:
      ".name"       : "name"
      ".size"       :
        observe: "attachment_file_size"
        onGet: (value) -> value.fileSize()
      ".updated_at" :
        observe: "updated_at"
        onGet: (value) -> "#{moment(value).fromNow()}" if value
      ".created_at" :
        observe: "created_at"
        onGet: (value) -> "created #{moment(value).fromNow()}"

    events:
      "click"         : -> @trigger "document:clicked", @model
      "click .edit"   : -> @trigger "edit:document:clicked", @model
      "click .delete" : -> @trigger "delete:document:clicked", @model
      "dblclick .name": "onEditDocumentNameClicked"

    onEditDocumentNameClicked: ->
      console.log 'edit'

    onRender: ->
      @stickit()

    onClose: ->
      clearInterval(@timer)

    templateHelpers: ->

      icon: ->
        switch @attachment_file_type
          when "html" then "globe"
          else "file"


  class List.Documents extends App.Views.CompositeView
    template: "documents/list/documents"
    itemView: List.Document
    emptyView: List.Empty
    itemViewContainer: "tbody"

    ui:
      "documents"  : "#documents > table"

    events:
      "click .new_folder": "newFolder"

    newFolder: ->
      @folder = new @collection.model()
      console.log 'new folder', @folder
      @collection.add @folder
      @render()

    onRender: ->
      @ui.documents.dataTable
        paging: true
        info: true
        language:
          search: "_INPUT_"
          emptyTable: "No files added"
          searchPlaceholder: "Filter documents..."
          zeroRecords: "No files matching"
      @validateit()

