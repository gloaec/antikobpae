@Antikobpae.module "FolderFilesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Empty extends App.Views.ItemView
    template: "folder_files/list/_empty"

  class List.File extends App.Views.ItemView
    template: "folder_files/list/_file"
    tagName: 'tr'

    initialize: ->
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
          when 1 then "Pending"
          when 2 then "Indexing"
          when 3 then "Indexed"
          else 'Unknown'
      ".created_at" :
        observe: "created_at"
        onGet: (value) -> "created #{moment(value).fromNow()}"

    events:
      "click"         : -> @trigger "file:clicked", @model
      "click .edit"   : -> @trigger "edit:file:clicked", @model
      "click .delete" : -> @trigger "delete:file:clicked", @model
      "dblclick .name": "onEditFileNameClicked"

    onEditFileNameClicked: ->
      console.log 'edit'

    onRender: ->
      @stickit()

    templateHelpers: ->
      status_class: ->
        switch @status
          when 1 then 'default'
          when 2 then 'info'
          when 3 then 'success'
          else 'warning hidden'

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
          search: "_INPUT_"
          emptyTable: "Folder is empty"
          searchPlaceholder: "Filter files..."
          zeroRecords: "No files matching"
        aoColumns: [{sWidth: 1}, {}, {}, {}, {}]
        bAutoWidth: false

