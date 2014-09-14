do (Backbone, Marionette) ->
	
  class Marionette.Region.Dialog extends Marionette.Region
	
    constructor: ->
      _.extend @, Backbone.Events

    open: (view) ->
      @$el.empty().append($('<div>').addClass('modal-dialog')
        .append($('<div>').addClass('modal-content').append(view.el)))

    onShow: (view) ->
      @setupBindings view
			
      options = @getDefaultOptions _.result(view, "dialog")
      @$el.modal options
      @$el.on "hidden.bs.modal", =>
        @closeDialog()
		
    getDefaultOptions: (options = {}) ->
      _.defaults options,
        backdrop: true
        keyboard: true
        show: true
        remote: false
		
    setupBindings: (view) ->
      @listenTo view, "dialog:close", @closeDialog
      @listenTo view, "dialog:title", @titleizeDialog
		
    closeDialog: ->
      @$el.modal 'hide'
      @stopListening()
      @close()
      @$el.empty()
		
    titleizeDialog: (title) ->
      @$('.modal-title').html title
