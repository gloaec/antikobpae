@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Scan extends Entities.Model
    defaults: ->
      name: "Scan #{moment().format('lll')}"
      folder: App.current_user.get('scans_folder')

    urlRoot: ->
      if @isNew()
        "/folders/#{@get('folder').id}/scans"
      else
        "/scans"

    relations: [
      type: Backbone.One
      key: 'folder'
      relatedModel: 'Antikobpae.Entities.Folder'
    ]

  class Entities.ScansCollection extends Entities.Collection
    model: Entities.Scan

  API =
    getScans: (params = {}) ->
      _.defaults params, {}
      scans = new Entities.ScansCollection
      scans.url = "/scans"
      scans.fetch
        reset: true
        data: params
      scans
    
  App.reqres.setHandler "scan:entities", ->
    API.getScans()
  
  App.reqres.setHandler "dashboard:scan:entities", ->
    API.getScans limit: 5

  App.reqres.setHandler "header:scan:entities", ->
    API.getScans limit: 3
