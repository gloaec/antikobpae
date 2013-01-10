$ = jQuery.sub()
Document = App.Document

$.fn.item = ->
  elementID   = $(@).data('id')
  elementID or= $(@).parents('[data-id]').data('id')
  Document.find(elementID)

class New extends Spine.Controller
  events:
    'click [data-type=back]': 'back'
    'submit form': 'submit'
    
  constructor: ->
    super
    @active @render
    
  render: ->
    @html @view('documents/new')

  back: ->
    @navigate '/documents'

  submit: (e) ->
    e.preventDefault()
    document = Document.fromForm(e.target).save()
    @navigate '/documents', document.id if document

class Edit extends Spine.Controller
  events:
    'click [data-type=back]': 'back'
    'submit form': 'submit'
  
  constructor: ->
    super
    @active (params) ->
      @change(params.id)
      
  change: (id) ->
    @item = Document.find(id)
    @render()
    
  render: ->
    @html @view('documents/edit')(@item)

  back: ->
    @navigate '/documents'

  submit: (e) ->
    e.preventDefault()
    @item.fromForm(e.target).save()
    @navigate '/documents'

class Show extends Spine.Controller
  events:
    'click [data-type=edit]': 'edit'
    'click [data-type=back]': 'back'

  constructor: ->
    super
    @active (params) ->
      @change(params.id)

  change: (id) ->
    @item = Document.find(id)
    @render()

  render: ->
    @html @view('documents/show')(@item)

  edit: ->
    @navigate '/documents', @item.id, 'edit'

  back: ->
    @navigate '/documents'

class Index extends Spine.Controller
  events:
    'click [data-type=edit]':    'edit'
    'click [data-type=destroy]': 'destroy'
    'click [data-type=show]':    'show'
    'click [data-type=new]':     'new'

  constructor: ->
    super
    Document.bind 'refresh change', @render
    Document.fetch()
    
  render: =>
    documents = Document.all()
    @html @view('documents/index')(documents: documents)
    
  edit: (e) ->
    item = $(e.target).item()
    @navigate '/documents', item.id, 'edit'
    
  destroy: (e) ->
    item = $(e.target).item()
    item.destroy() if confirm('Sure?')
    
  show: (e) ->
    item = $(e.target).item()
    @navigate '/documents', item.id
    
  new: ->
    @navigate '/documents/new'
    
class App.Documents extends Spine.Stack
  controllers:
    index: Index
    edit:  Edit
    show:  Show
    new:   New
    
  routes:
    '/documents/new':      'new'
    '/documents/:id/edit': 'edit'
    '/documents/:id':      'show'
    '/documents':          'index'
    
  default: 'index'
  className: 'stack documents'