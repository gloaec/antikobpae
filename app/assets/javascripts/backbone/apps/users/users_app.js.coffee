@Antikobpae.module "UsersApp", (UsersApp, App, Backbone, Marionette, $, _) ->

  class UsersApp.Router extends Marionette.SubRouter

    prefix: "users"

    appRoutes:
      ""         : "list"
      "new"      : "new"
      ":id"      : "show"
      ":id/edit" : "edit"
    
  API =
    list: (options) ->
      new UsersApp.List.Controller options

    new: (options) ->
      new UsersApp.New.Controller options

    show: (id, user=false) ->
      new UsersApp.Show.Controller id: id, user: user

    edit: (id, user=false) ->
      new UsersApp.Edit.Controller id: id, user: user

    delete: (id, user=false) ->
      user.destroy()
      
  App.vent.on "users:clicked", (users) ->
    App.navigate "users"
    API.list users

  App.vent.on "user:clicked", (user) ->
    App.navigate "users/#{user.id}"
    API.show user.id, user

  App.vent.on "edit:user:clicked", (user) ->
    App.navigate "users/#{user.id}/edit"
    API.edit user.id, user

  App.vent.on "delete:user:clicked", (user) ->
    App.navigate "users/#{user.id}/delete"
    API.delete user.id, user

  App.addInitializer ->
    new UsersApp.Router
      controller: API
