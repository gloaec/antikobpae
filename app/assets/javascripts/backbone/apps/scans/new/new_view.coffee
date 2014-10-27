@Antikobpae.module "ScansApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Toolbar extends App.Views.ItemView
    template: "scans/new/_toolbar"
    className: "btn-group"

    ui:
      uploadBtn     : '.new-folder-upload'
      dropdown      : '.dropdown'
      dropdownToggle: '.dropdown-toggle'

    events:
      "click .new-folder-document" : -> @trigger "new:folder:document:clicked", @model
      "click .new-folder-webpage"  : -> @trigger "new:folder:webpage:clicked", @model
      #"click .new-folder-upload"   : -> @trigger "new:folder:upload:clicked", @model

    onRender: ->
      _.defer => @initUploader()

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
        @ui.uploadBtn.attr(title: "Runtime: #{params.runtime}").tooltip()


      uploader.bind 'PostInit', (up, params) =>
        console.info "PostInit", up, params
        @$el.removeClass('open').css(opacity: 1)

      # Chrome FIX:
      @$el.css(opacity: 0).addClass('open')

      # Must init first to avoid default binding
      uploader.init()

      uploader.bind 'FilesAdded', (up, files) =>
        $.each files, (i, file) =>
          console.info "File ##{file.id} added", file.percent
          @collection.add _.extend file,
            name: file.name #_.truncate(file.name, 40)
            updated_at: new Date()
            tr_class: if i%2 then 'even' else 'odd'
            state: 0
            attachment_file_size: plupload.formatSize(file.size)
            attachment_file_type: file.name.split('.').pop()
            user: App.current_user
            progress: 0
        uploader.refresh() # Reposition Flash/Silverlight
        uploader.start()
      
      uploader.bind 'UploadProgress', (up, file) =>
        console.info "Upload ##{file.id}", file.percent
        @collection.get(file.id).set progress: file.precent
      
      uploader.bind 'Error', (up, err) =>
        console.error 'ERROR', up, err
        up.refresh() # Reposition Flash/Silverlight
      
      uploader.bind 'FileUploaded', (up, file) =>
        console.info "File ##{file.id} Uploaded !"
        @collection.get(file.id).set progress: file.percent


  class New.Form extends App.Views.ItemView
    template: "scans/new/_form"

    initialize: ->
      @listenTo @model, 'validated', (_, __, attrs) => @showErrors(attrs)

    ui:
      "name"       : "#name"
      "dataTable"  : "#dataTable"

    events:
      'submit form' : 'formSubmitted'

    bindings:
      "#name"      : "name"

    onRender: ->
      @stickit()
      @validateit()

    formSubmitted: (e) ->
      e.preventDefault()
      if @model.isValid(true)
        @model.save null,
          success: =>
            @collection.add @model
            App.execute "flash:success", "Post ##{@model.id} successfully created"
            App.navigate "posts", trigger: true
          error: (post, jqXHR) =>
            @showErrors $.parseJSON(jqXHR.responseText).errors

  class New.Layout extends App.Views.Layout
    template: "scans/new/new_layout"

    regions:
      formRegion:  "#form-region"
      filesRegion: "#files-region"
