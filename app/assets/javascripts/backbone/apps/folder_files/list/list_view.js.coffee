@Antikobpae.module "FolderFilesApp.List", (List, App, Backbone, Marionette, $, _) ->

  status_class = (status) ->
    switch status
      when -1 then 'label-danger'
      when 1  then 'label-default'
      when 2  then 'label-info'
      when 3  then 'bg-green'
      else 'label-warning hidden'
  

  class List.Empty extends App.Views.ItemView
    template: "folder_files/list/_empty"

  class List.File extends App.Views.ItemView
    template: "folder_files/list/_file"
    tagName: 'tr'

    initialize: ->
      if @model instanceof App.Entities.Document
        @type = 'document'
      else if @model instanceof App.Entities.Folder
        @type = 'folder'
      else if @model instanceof App.Entities.Scan
        @type = 'scan'
      @timer = setInterval =>
        @model.trigger "change:updated_at", @model
        @model.trigger "change:created_at", @model
      , 30000

    bindings:
      ".name"       :
        observe: "name"
        onGet: (value) -> _(value).truncate(50)
      ".size"       :
        observe: "attachment_file_size"
        onGet: (value) -> value?.fileSize?() or '--'
      ".updated_at" :
        observe: "updated_at"
        onGet: (value) -> "#{moment(value).fromNow()}" if value
      ".status"       :
        observe: "status"
        onGet: (value) -> switch value
          when -1 then "Error"
          when 0  then "Uploading"
          when 1  then "Pending"
          when 2  then "Indexing"
          when 3  then "Indexed"
          else 'Unknown'
      ".created_at" :
        observe: "created_at"
        onGet: (value) -> "created #{moment(value).fromNow()}"

    modelEvents:
      'change status': 'onStatusChange'

    ui:
      status: '.status'

    events:
      "click"         : -> @trigger "file:clicked", @model, @type
      "click .edit"   : -> @trigger "edit:file:clicked", @model, @type
      "click .delete" : -> @trigger "delete:file:clicked", @model, @type
      "dblclick .name": "onEditFileNameClicked"

    onEditFileNameClicked: ->
      console.log 'edit'

    onStatusChange: =>
      @ui.status.removeClass "label-default label-warning label-info bg-green"
      @ui.status.addClass status_class @model.get 'status'

    onRender: ->
      @stickit()

    templateHelpers: ->
      status_class: ->
        status_class @status

    onClose: ->
      clearInterval(@timer)


  class List.Files extends App.Views.CompositeView
    template: "folder_files/list/files"
    itemView: List.File
    emptyView: List.Empty
    itemViewContainer: "tbody"

    ui:
      "files"  : "#files > table"

    events:
      "click .new_folder": "newFolder"

    collectionEvents:
      'add': "render"

    initialize: ->
      @timer = setInterval =>
        unless @collection.getPendingDocuments().isEmpty()
          @collection.fetch reset: false
      , 2000

    newFolder: ->
      @folder = new @collection.model()
      console.log 'new folder', @folder
      @collection.add @folder
      @render()

    onRender: ->
      #@validateit()
      @ui.files.dataTable
        paging: true
        info: true
        language:
          emptyTable: "Folder is empty"
          searchPlaceholder: "Filter files..."
          zeroRecords: "No files matching"
        aoColumns: [{sWidth: 1}, {}, {}, {}, {}]
        bAutoWidth: false

    onClose: ->
      clearInterval @timer
