moduleKeywords = ['extended', 'included']

class Module
  # Extend the base object itself like a static method
  @extend: (obj) ->
    console.log "extend", obj
    for key, value of obj when key not in moduleKeywords
      console.log "  ", key, ":", value
      @[key] = value

    obj.extended?.apply(@)
    @

  # Include methods on the object prototype
  @include: (obj) ->
    console.log "include", obj
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      console.log "  ", key, ":", value
      @::[key] = value

    obj.included?.apply(@)
    @

  # Add methods on this prototype that point to another method
  # on another object's prototype.
  @delegate: (args...) ->
    target = args.pop()
    @::[source] = target::[source] for source in args

  # Create an alias for a function
  @aliasFunction: (to, from) ->
    @::[to] = (args...) => @::[from].apply @, args

  # Create an alias for a property
  @aliasProperty: (to, from) ->
    Object.defineProperty @::, to,
      get: -> @[from]
      set: (val) -> @[from] = val

  # Execute a function in the context of the object, and pass
  # a reference to the object's prototype.
  @included: (func) -> func.call @, @::
