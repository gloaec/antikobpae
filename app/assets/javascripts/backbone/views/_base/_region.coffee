@Antikobpae.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  _show = Backbone.Marionette.Region::show

  _.extend Backbone.Marionette.Region::,

	  #    show: (view)->
	  #      @ensureEl()
	  #      console.info 'render', view
	  #      @close ->
	  #        return if @currentView && @currentView != view
	  #        @currentView = view
	  #        @open view, ->
	  #          view.onShow() if view.onShow
	  #          view.trigger "show"
	  #          @onShow(view) if @onShow
	  #          @trigger "view:show", view
  
    onBeforeEmpty: (cb) ->
      view.$el.fadeOut "fast"
  
    onShow: (view, callback)->
      view.$el.hide().fadeIn "fast"
