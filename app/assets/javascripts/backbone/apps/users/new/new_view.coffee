@Antikobpae.module "UsersApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Toolbar extends App.Views.ItemView
    template: "users/new/_toolbar"

    events:
      "click .create-user"   : -> @trigger "create:user:clicked", @model

  class New.UserGroup extends App.Views.ItemView
    template: "users/new/_group"
    tagName: "span"
    className: "btn-checkbox"

    onRender: ->
      @$el.btn_checkbox()

  class New.UserGroups extends App.Views.CollectionView
    itemView: New.UserGroup

  class New.Form extends App.Views.ItemView
    template: "users/new/_form"

    initialize: ->
      @listenTo @model, 'validated', (_, __, attrs) => @showErrors(attrs)

    ui:
      "name"         : "#name"

    events:
      'submit form' : 'formSubmitted'

    bindings:
      "#name"      : "name"

    onRender: ->
      @stickit()
      @validateit()

    formSubmitted: (e) ->
      e.preventDefault()
      if @model.isValid(true)
        @model.save null,
          success: =>
            @collection.add @model
            App.execute "flash:success", "Post ##{@model.id} successfully created"
            App.navigate "posts", trigger: true
          error: (post, jqXHR) =>
            @showErrors $.parseJSON(jqXHR.responseText).errors

  class New.Layout extends App.Views.Layout
    template: "users/new/new_layout"

    regions:
      formRegion:   "#form-region"
      groupsRegion: "#groups-region"
