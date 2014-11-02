@Antikobpae.module "SidebarSearchApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "sidebar_search/list/list_layout"

    regions:
      formRegion:    "#form-region"
      resultsRegion: "#results-region"
  
  class List.Form extends App.Views.ItemView
    template: "sidebar_search/list/_form"
    
    ui:
      input: "input[type='text']"
      clear: ".clear"

    events:
      "submit form" : "formSubmitted"
      "keyup input" : "keyPressed"
      "click .clear": "clearClicked"
 
    onRender: ->
      @ui.clear.hide()

    keyPressed: (e) ->
      val = $.trim @ui.input.val()
      if val.length > 2
        if val != @val
          clearTimeout @timer
          @timer = setTimeout =>
            @trigger "search:typeahead", val
          ,   500
      else
        clearTimeout @timer
        @trigger "search:typeahead"
      if val.length == 0
        @ui.clear.hide()
      else
        @ui.clear.show()
      @val = val

    formSubmitted: (e) ->
      e.preventDefault()
      val = $.trim @ui.input.val()
      @trigger "search:submitted", val

    clearClicked: (e) ->
      clearTimeout @timer
      @trigger "search:typeahead"
      @ui.input.val('')
      @ui.clear.hide()
  
  class List.Document extends App.Views.ItemView
    template: "sidebar_search/list/_document"
    tagName: "li"
  
  class List.Empty extends App.Views.ItemView
    template: "sidebar_search/list/_empty"
    tagName: "li"
  
  class List.Documents extends App.Views.CollectionView
    template: "sidebar_search/list/_documents"
    itemView: List.Document
    emptyView: List.Empty
    tagName: "ul"
    className: "sub-menu"
  
  class List.Hero extends App.Views.ItemView
    template: "sidebar_search/list/_hero"
    className: "sub-menu clearfix"
