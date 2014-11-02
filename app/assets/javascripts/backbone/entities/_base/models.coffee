@Antikobpae.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Model extends Backbone.Model

    @mixin 'selectable'
    @mixin 'storable'
    @mixin 'validable'

    save: (key, val, options) ->
      if not key? or _.isObject(key)
        attrs = key
        options = val
      else
        (attrs = {})[key] = val
      {success} = options
      options.success = (model, resp, options) =>
        @store()
        success(model, resp, options) if success
      attributes = @attributes
      attributes = _.pick attributes, @whitelist if @whitelist?
      attributes = _.omit attributes, @blacklist if @blacklist?
      options.data = JSON.stringify _.extend(attributes, attrs)
      options.type = if @get('id')? then "PUT" else "POST"
      options.contentType = "application/json"
      super attrs, options

    parse: (data) ->
      if _.isObject data
        for key, val of data
          data[key] = new Date(val) if _(key).endsWith '_at'
      super data
 
    toJSON: ->
      json = super
      json['icon'] or= @icon() if _.isFunction(@icon)
      json['url'] or= @url() if _.isFunction(@url) and @urlRoot?
      json
