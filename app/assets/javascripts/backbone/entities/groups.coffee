@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->
	
  class Entities.Group extends Entities.Model

    urlRoot: -> "/groups"

    relations: [
      type: Backbone.Many
      key: 'users'
      relatedModel: 'Antikobpae.Entities.User'
    ]

    toJSON: ->
      json = super
      json

  class Entities.GroupsCollection extends Entities.Collection

    model: Entities.Group

    url: -> "/groups"
	

  API =
    getGroups: ->
      groups = new Entities.GroupsCollection
      groups.fetch()
      groups

    getGroup: (id) ->
      group = new Entities.Group id: id
      group.fetch()
      group
	
  App.reqres.setHandler "group:entities", ->
    API.getGroups()

  App.reqres.setHandler "group:entity", (id) ->
    API.getGroup(id)
