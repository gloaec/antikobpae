@Antikobpae.module "UsersApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Toolbar extends App.Views.ItemView
    template: "users/new/_toolbar"

    events:
      "click .create-user"   : -> @trigger "create:user:clicked", @model

  class New.UserGroup extends App.Views.ItemView
    template: "users/new/_group"
    tagName: "span"
    className: "btn-checkbox"
    
    ui:
      checkbox: 'input[type=checkbox]'

    events:
      'click' : 'toggleGroup'

    toggleGroup: =>
      console.log "TOGGLE", @model, @collection,
      if @ui.checkbox.is(':checked')
        @collection.add @model
      else
        @collection.remove @model

    onRender: ->
      @$el.btn_checkbox()

  class New.UserGroups extends App.Views.CollectionView
    itemView: New.UserGroup

    itemViewOptions: ->
      collection: @model.get 'groups'

  class New.Form extends App.Views.ItemView
    template: "users/new/_form"

    initialize: ->
      @listenTo @model, 'validated', (_, __, attrs) => @showErrors(attrs)
      @listenTo @, 'form:submitted', @formSubmitted

    ui:
      "name"                   : "#name"
      "email"                  : "#email"
      "password"               : "#password"
      "password_confirmation"  : "#password_confirmation"

    bindings:
      "#name"                  : "name"
      "#email"                 : "email"
      "#password"              : "password"
      "#password_confirmation" : "password_confirmation"

    onRender: ->
      @stickit()
      @validateit()

    formSubmitted: (user) =>
      if @model.isValid(true)
        @model.save null,
          success: =>
            @collection.add @model
            App.execute "flash:success", "User ##{@model.id} successfully created"
            App.navigate "users", trigger: true
          error: (post, jqXHR) =>
            console.error post, jqXHR.responseJSON.errors
            @showErrors jqXHR.responseJSON.errors


  class New.Layout extends App.Views.Layout
    template: "users/new/new_layout"

    regions:
      formRegion:   "#form-region"
      groupsRegion: "#groups-region"

    ui:
      'form' : 'form'

    events:
      'submit form' : (e) ->
        e.preventDefault()
        @trigger 'form:submitted', @model

    initialize: ()->
      @listenTo @, 'create:user:clicked', @createUserClicked

    createUserClicked: (user) ->
      @ui.form.submit()
