@Antikobpae.module "CoreApp.NotFound", (NotFound, App, Backbone, Marionette, $, _) ->
  
  class NotFound.NotFound extends App.Views.ItemView
    template: "_core/not_found/page"

    onRender: -> App.mainRegion.$el.addClass('not-found')
    onClose: -> App.mainRegion.$el.removeClass('not-found')
