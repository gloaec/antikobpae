$ = jQuery.sub()
Folder = App.Folder

$.fn.item = ->
  elementID   = $(@).data('id')
  elementID or= $(@).parents('[data-id]').data('id')
  Folder.find(elementID)

class New extends Spine.Controller
  events:
    'click [data-type=back]': 'back'
    'submit form': 'submit'
    
  constructor: ->
    super
    @active @render
    
  render: ->
    @html @view('folders/new')

  back: ->
    @navigate '/folders'

  submit: (e) ->
    e.preventDefault()
    folder = Folder.fromForm(e.target).save()
    @navigate '/folders', folder.id if folder

class Edit extends Spine.Controller
  events:
    'click [data-type=back]': 'back'
    'submit form': 'submit'
  
  constructor: ->
    super
    @active (params) ->
      @change(params.id)
      
  change: (id) ->
    @item = Folder.find(id)
    @render()
    
  render: ->
    @html @view('folders/edit')(@item)

  back: ->
    @navigate '/folders'

  submit: (e) ->
    e.preventDefault()
    @item.fromForm(e.target).save()
    @navigate '/folders'

class Show extends Spine.Controller
  events:
    'click [data-type=edit]': 'edit'
    'click [data-type=back]': 'back'

  constructor: ->
    super
    @active (params) ->
      @change(params.id)

  change: (id) ->
    @item = Folder.find(id)
    @render()

  render: ->
    @html @view('folders/show')(@)

  edit: ->
    @navigate '/folders', @item.id, 'edit'

  back: ->
    @navigate '/folders'

class Index extends Spine.Controller
  events:
    'click [data-type=edit]':    'edit'
    'click [data-type=destroy]': 'destroy'
    'click [data-type=show]':    'show'
    'click [data-type=new]':     'new'

  constructor: ->
    super
    Folder.bind 'refresh change', @render
    Folder.fetch()
    
  render: =>
    folders = Folder.all()
    @html @view('folders/index')(folders: folders)
    
  edit: (e) ->
    item = $(e.target).item()
    @navigate '/folders', item.id, 'edit'
    
  destroy: (e) ->
    item = $(e.target).item()
    item.destroy() if confirm('Sure?')
    
  show: (e) ->
    item = $(e.target).item()
    @navigate '/folders', item.id
    
  new: ->
    @navigate '/folders/new'
    
class App.Folders extends Spine.Stack
  controllers:
    index: Index
    edit:  Edit
    show:  Show
    new:   New
    
  routes:
    '/folders/new':      'new'
    '/folders/:id/edit': 'edit'
    '/folders/:id':      'show'
    '/folders':          'index'
    
  default: 'index'
  className: 'stack folders'