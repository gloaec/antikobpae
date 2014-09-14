do (Backbone, Cocktail) ->

  Backbone.Model:: = Backbone.AssociatedModel::
  Cocktail.patch(Backbone)

  _.extend Backbone.actAs.Mementoable,
    store: -> @storeMemento.apply @, arguments
    restore: -> @restoreMemento.apply @, arguments

  Selectable =
    initialize: ->
      _.extend @, new Backbone.Picky.Selectable @

  OneSelectable =
    initialize: ->
      _.extend @, new Backbone.Picky.SingleSelectable @

  ManySelectable =
    initialize: ->
      _.extend @, new Backbone.Picky.MutliSelectable @

  Cocktail.mixins =
    associable:       {}             # Default
    selectable:       Selectable     # OK
    one_selectable:   OneSelectable  # OK
    many_selectable:  ManySelectable # OK
    storable:         Backbone.actAs.Mementoable # OK
    validable:        Backbone.Validation.mixin  # OK
