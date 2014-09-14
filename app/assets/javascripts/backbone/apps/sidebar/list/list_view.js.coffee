@Antikobpae.module "SidebarApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Sidebar extends App.Views.ItemView
    template: "sidebar/list/sidebar"

    ui:
      menu   : '#side-menu'
      sidebar: '.sidebar-collapse'

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
