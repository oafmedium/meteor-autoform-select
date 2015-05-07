@BlurActive = class BlurActive
  @add: (element, namespace, callback) ->
    active = null

    $(document).on "mousedown.#{namespace}", (event) ->
      active = $(event.target).get(0)

    $(document).on "keydown.#{namespace}", (event) ->
      active = $(event.target).get(0)

    $(document).on "click.#{namespace}", (event) ->
      event.active = event.target
      callback.call @, event

    $(element).on "blur.#{namespace}", (event) ->
      event.active = active
      callback.call @, event

  @remove: (element, namespace) ->
    $(document).off "mousedown.#{namespace}"
    $(document).off "keydown.#{namespace}"
    $(document).off "click.#{namespace}"
    $(element).off "blur.#{namespace}"
