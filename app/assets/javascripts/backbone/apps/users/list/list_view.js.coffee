@Antikobpae.module "UsersApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Toolbar extends App.Views.ItemView
    template: "users/list/_toolbar"
    className: "btn-group pull-right"

  class List.Empty extends App.Views.ItemView
    template: "users/list/_empty"

  class List.User extends App.Views.ItemView
    template: "users/list/_user"
    tagName: 'tr'

    initialize: ->
      @timer = setInterval =>
        @model.trigger "change:updated_at", @model
        @model.trigger "change:created_at", @model
      , 30000

    bindings:
      ".name"       : "name"
      ".email"      : "email"
      ".updated_at" :
        observe: "updated_at"
        onGet: (value) -> "#{moment(value).fromNow()}" if value
      ".created_at" :
        observe: "created_at"
        onGet: (value) -> "created #{moment(value).fromNow()}"

    events:
      "click .show"   : -> @trigger "user:clicked", @model
      "click .edit"   : -> @trigger "edit:user:clicked", @model
      "click .delete" : "onDeleteUserClicked" #-> @trigger "delete:user:clicked", @model
      "dblclick .name": "onEditUserNameClicked"

    onDeleteUserClicked: (e) =>
      e.stopPropagation()
      bootbox.confirm "Are you sure you want to delete user '#{@model.get 'name'}'", (response) =>
        if response
          @model.destroy
            success: =>
              App.execute 'flash:success', "User '#{@model.get 'name'}' successfully deleted"
              App.navigate '/users', trigger: true


    onEditUserNameClicked: ->
      console.log 'edit'

    onRender: ->
      @stickit()

    onClose: ->
      clearInterval(@timer)

    templateHelpers: {}

  class List.Users extends App.Views.CompositeView
    template: "users/list/users"
    itemView: List.User
    emptyView: List.Empty
    itemViewContainer: "tbody"

    ui:
      "users"  : "#users > table"

    events:
      "click .new_folder": "newFolder"

    newFolder: ->
      @folder = new @collection.model()
      console.log 'new folder', @folder
      @collection.add @folder
      @render()

    onRender: ->
      @ui.users.dataTable
        paging: true
        info: true
        language:
          search: "_INPUT_"
          emptyTable: "No files added"
          searchPlaceholder: "Filter users..."
          zeroRecords: "No files matching"
        aoColumns: [{sWidth: 1}, {}, {}, {}]
      @validateit()

