@Antikobpae.module "ScansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Toolbar extends App.Views.ItemView
    template: "scans/list/_toolbar"
    className: "btn-group pull-right"

    ui: {}

    events: {}

  class List.Empty extends App.Views.ItemView
    template: "scans/list/_empty"

  class List.Scan extends App.Views.ItemView
    template: "scans/list/_scan"
    tagName: 'a',
    className: 'list-group-item clearfix'

    initialize: ->
      @$el.prop 'href', @model.url()
      @timer = setInterval =>
        @model.trigger "change:updated_at", @model
      , 30000

    bindings:
      ".name":               "name"
      ".count_documents":    "count_documents"
      ".count_pending":      "count_pending"
      ".count_passed":       "count_passed"
      ".count_suspicious":   "count_suspicious"
      ".count_plagiarized":  "count_plagiarized"
      ".count_similarities": "count_similarities"
      ".count_sources":      "count_sources"
      ".updated_at":
        observe: "updated_at"
        onGet: (value) -> "modified #{moment(value).fromNow()}" if value
      ".sprogress":
        observe: "progress"
        onGet: (value) ->
          switch value
            when 0 then "Pending"
            when 100 then "Completed"
            else "#{value}% Complete"

    onRender: ->
      @stickit()

  class List.Scans extends App.Views.CompositeView
    template: "scans/list/scans"
    itemView: List.Scan
    emptyView: List.Empty
    itemViewContainer: "#scans"

    collectionEvents:
      'change': 'render'

    initialize: ->
      @timer = setInterval =>
        @collection.fetch()
      , 1000

    onClose: ->
      clearInterval(@timer)
