@Antikobpae.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.ItemView extends Marionette.ItemView

    templateHelpers: ->

	    #icon: ->
      	    #  switch @attachment_file_type
      	    #    when "html" then "globe"
      	    #    else "file"

    serializeData: ->
      json = super
      json['user'] or= App.current_user?.toJSON?() unless @model instanceof App.Entities.User
      json