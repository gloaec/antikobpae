@Antikobpae.module "UsersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Toolbar extends App.Views.ItemView
    template: "users/show/_toolbar"
    className: "btn-group pull-right"

    ui:
      buttons: 'button'

    events: {}

    onRender: ->
      @ui.buttons.tooltip()


  class Show.User extends App.Views.ItemView
    template: "users/show/user"

    bindings:
      '.name'  : 'name'
      '.email' : 'email'
      
    onRender: ->
      @stickit()

  class Show.UserGroup extends App.Views.ItemView
    template: "users/show/_group"
    tagName: "span"
    className: "btn-checkbox"

  class Show.UserGroups extends App.Views.CollectionView
    itemView: Show.UserGroup

    itemViewOptions: ->
      collection: @model.get 'groups'
