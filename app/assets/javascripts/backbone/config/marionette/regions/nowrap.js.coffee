do (Backbone, Marionette) ->
	
  class Marionette.Region.Nowrap extends Marionette.Region
	
    open: (view) ->
      @$el.html view.$el.children().clone(true)
