@Antikobpae.module "UsersApp.Show", (Show, App, Backbone, Marionette) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->

      if options.user
        user = options.user
        user.fetch()
      else
        user = App.request "user:entity", options.id

      userView = @getUserView user

      @show userView,
        loading: true
        page:
          breadcrumb: user
          title: 'Loading...'
          title_attribute: 'name'
          toolbar:
            view: @toolbarView user
            

    toolbarView: (user) ->
      toolbarView = @getToolbarView user
      toolbarView

    getToolbarView: (user) ->
      new Show.Toolbar
        model: user

    getUserView: (user) ->
      new Show.User
        model: user
