@Antikobpae.module "FolderDocumentsApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options) ->
      folder = options.folder or= App.request "folder:entity", options.folder_id
      type   = options.type or= 'document'

      @newFolderDocumentView = new App.Views.ItemView

      App.execute "when:fetched", folder, =>
        documents = folder.get('documents')
        document = new documents.model
          folder: folder
          attachment_file_type: switch type
            when 'webpage' then 'html'
            else 'file'

        @newFolderDocumentView = @getNewFolderDocumentView folder, document, documents, type

        #@listenTo @newFolderDocumentView, "form:submitted", =>
        # FIXME Hummm, pas très propre tout ça
        #
        @show @newFolderDocumentView,
          page:
            title: "New #{type.capitalize()}"
            breadcrumb: document
            toolbar:
              view: @toolbarView document

      @show @newFolderDocumentView,
        loading: {entities: folder}

    toolbarView: (document) ->
      toolbarView = @getToolbarView document

      toolbarView.on "create:folder:document:clicked", (document) =>
        @newFolderDocumentView.trigger "create:folder:document:clicked", document

      toolbarView

    getToolbarView: (document) ->
      new New.Toolbar
        model: document

    getNewFolderDocumentView: (folder, document, documents, type) ->
      params =
        folder     : folder
        model      : document
        collection : documents
      switch type
        when 'webpage' then new New.Webpage params
        else new New.Document params
