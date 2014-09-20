do (Backbone) ->
	
  _.extend Backbone.Marionette.Application::,

    navigate: (route, options = {}) ->
      @vent.trigger 'navigate', route, options
      Backbone.history.navigate route, options
      @highlightRoute(route)

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      unless _.isEmpty(frag)
        @highlightRoute("/#{frag}")
        frag
		
    highlightRoute: (href) ->
      console.log 'hightlight route', href
      $('.page-sidebar-menu li.active').removeClass('active')
      $('a').each (i, el)->
        if href.match($(el).attr('href'))
          $(el).parent('li').addClass('active')

    startHistory: (options = {}) ->
      _.defaults options,
        pushState: true

      if Backbone.history
        Backbone.history.start options
        if Backbone.history._hasPushState
          $(document).delegate "a[href^='/']", "click", (event) =>
            @delegateClick(event)

    delegateClick: (event) ->
      event = event || window.event
      target = event.currentTarget || event.srcElement || event.target

      # Get the anchor href and protcol
      href = $(target).attr("href")
      protocol = target.protocol + "//"
      passThrough = href.indexOf('special_url') >= 0 or $(target).data('reload')?
      passThrough ||= href.slice(protocol.length) is protocol
      passThrough ||= event.altKey or event.ctrlKey or event.metaKey or event.shiftKey

      unless passThrough
      # Ensure the protocol is not part of URL, meaning its relative.
      # Stop the event bubbling to ensure the link will not cause a page refresh.
        event.preventDefault()
        # Note by using Backbone.history.navigate, router events will not be
        # triggered. If this is a problem, change this to navigate on your
        # router.
        @navigate href, true
        false

    register: (instance, id) ->
      @_registry ?= {}
      @_registry[id] = instance
		
    unregister: (instance, id) ->
      delete @_registry[id]
		
    resetRegistry: ->
      oldCount = @getRegistrySize()
      for key, controller of @_registry
        controller.region.close()
      msg = "There were #{oldCount} controllers in the registry, there are now #{@getRegistrySize()}"
      if @getRegistrySize() > 0 then console.warn(msg, @_registry) else console.log(msg)
		
    getRegistrySize: ->
      _.size @_registry
