@Antikobpae.module "Components.Flash", (Flash, App, Backbone, Marionette, $, _) ->
	
  class Flash.FlashView extends App.Views.ItemView
    template: "flash/flash_view"

    attributes: ->
      class: @model.get('className')

    events:
      'click .close' : -> @close()

    onClose: ->
      @model.destroy()

  class Flash.FlashesView extends App.Views.CollectionView
    itemView  : Flash.FlashView
