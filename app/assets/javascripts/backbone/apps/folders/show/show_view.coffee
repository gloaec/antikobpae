@Antikobpae.module "FoldersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Folder extends App.Views.ItemView
    template: "folders/show/_folder"

    initialize: ->
      @collection = App.request 'folder:file:entities', @model
      @listenTo @model, 'add:comments remove:comments change:comments', @render, @
    
    ui:
      uploadBtn     : '.new-folder-upload'
      dropdown      : '.dropdown'
      dropdownToggle: '.dropdown-toggle'
      uploadRuntime : '.upload-runtime'
    
    bindings:
      '#title'  : 'title'
      '#content': 'content'
      '#nbcomments':
        observe: "comments"
        onGet: (value) -> value.size()

    events:
      "click .new-folder-folder"   : -> @trigger "new:folder:folder:clicked", @model
      "click .new-folder-document" : -> @trigger "new:folder:document:clicked", @model
      "click .new-folder-webpage"  : -> @trigger "new:folder:webpage:clicked", @model
      #"click .new-folder-upload"   : -> @trigger "new:folder:upload:clicked", @model
      
    onRender: ->
      @stickit()
      @initUploader()

    initUploader: (params={}) ->

      _.defaults params,
        url: "#{@model.url()}/documents"
        multipart_params:
          document_text_only: true
          authenticity_token: App.current_user.get 'authenticity_token'
          #'<%= request.session_options[:key] %>': '<%= request.session_options[:id] %>'
        runtimes      : 'html5,gears,flash,silverlight,browserplus'
	#drop_element  : "files-region"
        browse_button : @ui.uploadBtn[0]
	#container     : "files-region"
        max_file_size : '100mb'
        #rename: true
        filters: [
          title       : "AntiKobpae Supported Documents"
          extensions  : "doc,docx,pdf,rtf,txt,html"
        ]
        autostart : true

      uploader = new plupload.Uploader params

      uploader.bind 'Init', (up, params) =>
        console.info "Init", up, params
        @ui.uploadRuntime.text params.runtime

      uploader.bind 'PostInit', (up, params) =>
        console.info "PostInit", up, params
        @ui.dropdown.removeClass('open').css(opacity: 1)

      uploader.bind 'FilesAdded', (up, files) =>
        $.each files, (i, file) =>
          console.info "File ##{file.id} added", file.percent
          @collection.add _.extend file,
            name: _.truncate(file.name, 40)
            updated_at: new Date()
            tr_class: if i%2 then 'even' else 'odd'
            state: 0
            attachment_file_size: plupload.formatSize(file.size)
            attachment_file_type: file.name.split('.').pop()
            user: App.current_user
            progress: 0
        up.refresh() # Reposition Flash/Silverlight
        up.start()
      
      uploader.bind 'UploadProgress', (up, file) =>
        console.info "Upload ##{file.id}", file.percent
        @collection.get(file.id).set progress: file.precent
      
      uploader.bind 'Error', (up, err) =>
        console.error 'ERROR', up, err
        up.refresh() # Reposition Flash/Silverlight
      
      uploader.bind 'FileUploaded', (up, file) =>
        console.info "File ##{file.id} Uploaded !"
        @collection.get(file.id).set progress: file.percent
	
      @ui.dropdown.css(opacity: 0).addClass('open')
      uploader.init()

  class Show.Layout extends App.Views.Layout
    template: "folders/show/show_layout"

    regions:
      folderRegion:      "#folder-region"
      filesRegion:       "#files-region"
      breadcrumbsRegion: "#breadcrumbs-region"
