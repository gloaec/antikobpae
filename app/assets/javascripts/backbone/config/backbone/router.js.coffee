do (Backbone) ->
  _navigate = Backbone.history.navigate

  Backbone.history.navigate = (fragment, options) ->
    navigate = _navigate.call(@, fragment, options)
    @trigger 'navigate', fragment, options
    navigate
