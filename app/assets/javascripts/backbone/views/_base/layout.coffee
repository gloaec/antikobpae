@Antikobpae.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.Layout extends Marionette.Layout

    serializeData: ->
      json = super
      json['user'] or= App.current_user?.toJSON?() unless @model instanceof App.Entities.User
      json
