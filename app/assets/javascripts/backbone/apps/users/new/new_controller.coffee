@Antikobpae.module "UsersApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->
      users  = options.users  or= App.request "user:entities"
      groups = options.groups or= App.request "group:entities"
      user   = new users.model()

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @userGroupsView user, groups
        @formView user, users

      @show @layout,
        page:
          title: 'New User'
          breadcrumb: user
          toolbar:
            view: @toolbarView user, users
        loading:
          entities: user
    
    getLayoutView: ->
      new Show.Layout

    formView: (user, users) ->
      formView = @getFormView user, users

      @listenTo formView, "form:submitted", =>

      @show formView, region: @layout.formRegion

    userGroupsView: (user, groups) ->
      userGroupsView = @getUserGroupsView user, groups

      @show userGroupsView,
        region: @layout.groupsRegion
        loading:
          entities: groups

    toolbarView: (user, users) ->
      toolbarView = @getToolbarView user, users

      toolbarView.on "create:user:clicked", (user) =>
        @newFolderDocumentView.trigger "create:user:clicked", user

      toolbarView

    getFormView: (user, users) ->
      new New.Form
        model      : user
        collection : users

    getUserGroupsView: (user, groups) ->
      new New.UserGroups
        model      : user
        collection : groups

    getToolbarView: (user, users) ->
      new New.Toolbar
        model: user
        collection: users

    getLayoutView: ->
      new New.Layout

