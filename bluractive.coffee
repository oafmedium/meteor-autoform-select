@BlurActive = class BlurActive
  @add: (element, namespace, callback) ->
    active = null

    $(document).on "mousedown.#{namespace}", (event) ->
      active = $(event.target).get(0)

    $(document).on "keydown.#{namespace}", (event) ->
      active = $(event.target).get(0)

    $(element).on "blur.#{namespace}", (event) ->
      event.active = active
      callback.call @, event

  @remove: (element, namespace) ->
    $(document).off "mousedown.#{namespace}"
    $(document).off "keydown.#{namespace}"
    $(element).off "blur.#{namespace}"
