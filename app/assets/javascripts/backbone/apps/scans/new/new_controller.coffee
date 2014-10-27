@Antikobpae.module "ScansApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->

      scans = options.scans or= App.request "scan:entities"
      scan = new scans.model()
      folder = App.current_user.get('scans_folder')
      folder.fetch()
      files = App.request 'folder:document:entities', folder

      @layout = @getLayoutView()
      
      @listenTo @layout, "show", =>
        @formView scan, files
        @filesView folder, files

      @show @layout,
        page:
          title: "New Scan"
          title_attribute: 'name'
          breadcrumb: scan
          toolbar:
            view: @toolbarView folder, files
        loading: true

    formView: (scan, files) ->
      formView = @getFormView scan, files

      @listenTo formView, "form:submitted", =>

      @show formView, region: @layout.formRegion

    filesView: (folder, files) ->
      filesView = App.execute "list:folder:files",
        folder: folder
        files : files
        filter: "document"
        region: @layout.filesRegion

    toolbarView: (folder, files) ->
      toolbarView = @getToolbarView folder, files
      toolbarView

    getFormView: (scan, files) ->
      new New.Form
        model: scan
        collection: files

    getToolbarView: (folder, files) ->
      new New.Toolbar
        model: folder
        collection: files

    getLayoutView: ->
      new New.Layout
