@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->
	
  class Entities.User extends Entities.Model

    urlRoot: -> "/users"

    relations: [
      type: Backbone.One
      key: 'private_folder'
      relatedModel: 'Antikobpae.Entities.Folder'
    ,
      type: Backbone.One
      key: 'scans_folder'
      relatedModel: 'Antikobpae.Entities.Folder'
    ]

    toJSON: ->
      json = super
      json['private_folder_url'] or= @get('private_folder').url()
      json['scans_folder_url'] or= @get('scans_folder').url()
      json

  class Entities.UsersCollection extends Entities.Collection

    model: Entities.User

    url: -> "/users"
	

  API =
    getUsers: ->
      users = new Entities.UsersCollection
      users.fetch()
      users

    getUser: (id) ->
      user = new Entities.User id: id
      user.fetch()
      user
	
  App.reqres.setHandler "user:entities", ->
    API.getUsers()

  App.reqres.setHandler "user:entity", (id) ->
    API.getUser(id)
