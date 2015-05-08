Template.afOafSelect.events
  'keydown input.oafselect-input': (event, template) ->
    if event.keyCode in [9, 27]
      template.oafSelect.setShowDropdown false

    if event.keyCode is 8 and $(event.target).val() is ''
      template.oafSelect.unselectItem()

    if event.keyCode is 38 # cursor up
      template.oafSelect.setIndex template.oafSelect.getIndex() - 1

    if event.keyCode is 40 # cursor down
      template.oafSelect.setIndex template.oafSelect.getIndex() + 1

    if event.keyCode is 13
      event.preventDefault()
      template.$('.oafselect-dropdown-item.active').trigger 'click'

    dropdown = template.$('.oafselect-dropdown')
    top = dropdown.find('.active').position()?.top
    dropdown.scrollTop top + dropdown.scrollTop() if top?

  'keyup input.oafselect-input': (event, template) ->
    return if event.keyCode in [9, 27, 38, 40]
    template.oafSelect.setSearchValue $(event.target).val()

  'focus input.oafselect-input': (event, template) ->
    template.oafSelect.setShowDropdown true
    template.focused.set true

  'blur input.oafselect-input': (event, template) ->
    template.focused.set false

  'click .oafselect-input-wrapper': (event, template) ->
    template.$('input.oafselect-input').focus()

  'click .oafselect-selected-item .remove': (event, template) ->
    event.preventDefault()
    event.stopPropagation()
    target = $(event.target).closest '.oafselect-selected-item'
    template.oafSelect.unselectItem target.attr('data-value')
    template.$('input.oafselect-input').focus()

  'mouseover .oafselect-dropdown-item': (event, template) ->
    updateActive = ->
      target = $(event.target)
      target = target.closest('[data-value]') unless target.is('[data-value]')
      value = target.attr('data-value')
      index = template.oafSelect.getItemIndex value
      template.oafSelect.setIndex index

    if template.oafSelect.getOptions().throttling
      Meteor.clearTimeout template.hoverTimeout
      template.hoverTimeout = Meteor.setTimeout updateActive, 125
    else
      updateActive()

  'click .oafselect-dropdown-item': (event, template) ->
    template.oafSelect.selectItem $(event.currentTarget).attr 'data-value'
    if template.oafSelect.getAtts().multiple
      template.$('input.oafselect-input').focus()

  'click .oafselect-dropdown-item.create': (event, template) ->
    template.oafSelect.createItem()

Template.afOafSelect.helpers
  atts: ->
    instance = Template.instance()
    instance?.oafSelect.getAtts()
  searchValue: ->
    instance = Template.instance()
    instance?.oafSelect.getSearchValue()
  oafSelectOptions: ->
    instance = Template.instance()
    return instance.oafSelect.getOptions()
  dropdownItems: ->
    instance = Template.instance()
    instance?.oafSelect.getDropdownItems()
  selectedItems: ->
    instance = Template.instance()
    instance?.oafSelect.getSelectedItems()
  createText: ->
    instance = Template.instance()
    instance?.oafSelect.getCreateText()
  placeholder: ->
    instance = Template.instance()
    selected = instance?.oafSelect.getSelectedItems()
    return if selected.length > 0
    if typeof @atts.placeholder is 'function'
      @atts.placeholder()
    else
      @atts.placeholder
  showDropdown: ->
    instance = Template.instance()
    instance?.oafSelect.getShowDropdown()
  itemIndex: ->
    instance = Template.instance()
    instance?.oafSelect.getItemIndex @value
  indexMatch: ->
    instance = Template.instance()
    return unless instance?.oafSelect.getShowDropdown()

    index = instance?.oafSelect.getIndex()
    itemIndex = instance?.oafSelect.getItemIndex @value
    index is itemIndex
  focus: ->
    instance = Template.instance()
    instance?.focused.get()

Template.afOafSelect.onCreated ->
  @oafSelect = new OafSelect this
  @focused = new ReactiveVar false
Template.afOafSelect.onRendered ->
Template.afOafSelect.onDestroyed ->
