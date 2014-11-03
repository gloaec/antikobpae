@Antikobpae.module "UsersApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      users = App.request "user:entities"

      usersView = @getUsersView users

      usersView.on "childview:edit:user:clicked", (iv, user) ->
        App.vent.trigger "edit:user:clicked", user

      usersView.on "childview:user:clicked", (iv, user) ->
        App.vent.trigger "user:clicked", user

      usersView.on "childview:delete:user:clicked", (iv, user) ->
        App.vent.trigger "delete:user:clicked", user

      @show usersView,
        page:
          entities: users
          title: 'Loading'
          breadcrumb:
            icon: 'list'
            name: 'Users'
          toolbar:
            view: @toolbarView users

    toolbarView: (users) ->
      toolbarView = @getToolbarView users
      toolbarView

    getUsersView: (users) ->
      new List.Users
        collection: users

    getToolbarView: (folder, files) ->
      new List.Toolbar
        model: folder
        collection: files
