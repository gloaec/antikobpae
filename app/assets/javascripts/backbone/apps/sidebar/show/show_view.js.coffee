@Antikobpae.module "SidebarApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "sidebar/show/show_layout"

    ui:
      menu   : '#side-menu'
      sidebar: '.sidebar-collapse'

    regions:
      searchRegion: "#search-region"

    onRender: ->
      @ui.menu.metisMenu()
      $(window).bind "load resize", =>
        width = if window.innerWidth > 0 then window.innerWidth else screen.width
        if width < 768
          @ui.sidebar.addClass('collapse')
        else
          @ui.sidebar.removeClass('collapse')
      @trigger 'sidebar:rendered'
      App.getCurrentRoute()
