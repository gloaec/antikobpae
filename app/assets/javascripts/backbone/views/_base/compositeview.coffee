@Antikobpae.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.CompositeView extends Marionette.CompositeView
    itemViewEventPrefix: "childview"

    serializeData: ->
      json = super
      json['user'] or= App.current_user?.toJSON?() unless @model instanceof App.Entities.User
      json

