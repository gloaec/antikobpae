@Antikobpae.module "DashboardDocumentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Empty extends App.Views.ItemView
    template: "dashboard_documents/list/_empty"

  class List.Document extends App.Views.ItemView
    template: "dashboard_documents/list/_document"
    tagName: 'a',
    className: 'list-group-item clearfix'

    initialize: ->
      @$el.prop 'href', @model.url()
      @timer = setInterval =>
        @model.trigger "change:updated_at", @model
      , 30000

    bindings:
      ".name":
        observe: "name"
        onGet: (value) -> _(value).truncate(30)
      ".updated_at" :
        observe: "updated_at"
        onGet: (value) -> "modified #{moment(value).fromNow()}" if value

    onRender: ->
      @stickit()

  class List.Documents extends App.Views.CompositeView
    template: "dashboard_documents/list/documents"
    itemView: List.Document
    emptyView: List.Empty
    itemViewContainer: "#dashboard-documents"
