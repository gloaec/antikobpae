Spine.Controller.include
  view: (name) ->
    controller = name.split('/')[0]
    helpers = 
      link_to: (yld, url) -> 
        "<a href=\"#{url}\">#{yld}</a>"

    (item) ->
      JST["app/views/#{name}"]($.extend(item, helpers))
