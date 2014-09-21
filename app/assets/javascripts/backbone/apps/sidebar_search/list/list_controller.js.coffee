@Antikobpae.module "SidebarSearchApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @formView()
        @resultsView()

      @show @layout
    
    formView: ->
      formView = @getFormView()
      
      @listenTo formView, "search:submitted", (searchTerm) =>
      @listenTo formView, "search:typeahead", (searchTerm) =>
        @resultsView searchTerm

      @show formView, region: @layout.formRegion
    
    resultsView: (searchTerm = null) ->
      if searchTerm then @searchView(searchTerm) else @showHeroView()
    
    searchView: (searchTerm) ->
      documents = App.request "typeahead:document:entities", searchTerm

      documentsView = @getDocumentsView documents
      
      opts =
        region: @layout.resultsRegion
        loading: true
      
      opts.loading = { loadingType: "opacity" } if @layout.resultsRegion.currentView isnt @heroView
      
      @show documentsView, opts
    
    showHeroView: ->
      @heroView = @getHeroView()
      @show @heroView, region: @layout.resultsRegion
    
    getHeroView: ->
      new List.Hero
    
    getDocumentsView: (documents) ->
      new List.Documents
        collection: documents
    
    getFormView: ->
      new List.Form

    getLayoutView: ->
      new List.Layout
