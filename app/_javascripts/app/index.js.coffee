#= require json2
#= require jquery
#= require spine
#= require spine/manager
#= require spine/ajax
#= require spine/route
#= require spine/relation

#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers


class App extends Spine.Controller
  constructor: ->
    super
    
    # Initialize controllers:
    @append(@folders = new App.Folders)
    @append(@documents = new App.Document)
    #  ...
    
    Spine.Route.setup()    

window.App = App