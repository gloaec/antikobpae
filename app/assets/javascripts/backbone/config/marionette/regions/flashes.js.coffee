do (Backbone, Marionette) ->
	
  class Marionette.Region.Flashes extends Marionette.Region
	
    constructor: ->
      _.extend @, Backbone.Events

    onShow: (view) ->
      @setupBindings view
      options = @getDefaultOptions _.result(view, "dialog")
		
    getDefaultOptions: (options = {}) ->
      _.defaults options,
        backdrop: true
        keyboard: true
        show: true
        remote: false
		
    setupBindings: (view) ->
      @listenTo view, "flashes:close", @closeFlashes
		
    closeFlashes: ->
      @$el.modal 'hide'
      @stopListening()
      @close()
      @$el.empty()
