@Antikobpae.module "SidebarSearchApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "sidebar_search/list/list_layout"

    regions:
      formRegion:    "#form-region"
      resultsRegion: "#results-region"
  
  class List.Form extends App.Views.ItemView
    template: "sidebar_search/list/_form"
    
    ui:
      "input" : "input"

    events:
      "submit form" : "formSubmitted"
      "keyup input" : "keyPressed"
    
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
      @val = val

    formSubmitted: (e) ->
      e.preventDefault()
      val = $.trim @ui.input.val()
      @trigger "search:submitted", val
  
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
