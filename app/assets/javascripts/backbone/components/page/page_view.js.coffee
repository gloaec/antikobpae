@Antikobpae.module "Components.Page", (Page, App, Backbone, Marionette, $, _) ->
  
  class Page.LayoutView extends App.Views.Layout
    template: "page/page_layout"
    
    regions:
      contentRegion     : '#page-content-region'
      breadcrumbsRegion : '#page-breadcrumbs-region'
      toolbarRegion     : '#page-toolbar-region'

    onShow: ->
      opts = @_getOptions()
    
    onClose: ->
    
    _getOptions: ->
