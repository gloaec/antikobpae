messages = ['info', 'notice', 'warning', 'error', 'alert', 'success']

hideAllMessages = ->
  for message in messages
    m = $('.flash.' + message)
    m.css 'margin-top', -m.outerHeight()
	  
showMessage = (type) ->
  $('.flash.' + type).animate 'margin-top': 0, 500

$(document).ready ->
  hideAllMessages()
  for message in messages
    showMessage message
  $('.flash').click ->		
    $(@).animate 'margin-top': -$(@).outerHeight(), 500          