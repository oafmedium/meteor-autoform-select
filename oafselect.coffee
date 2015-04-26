class OafSelect
  constructor: (@instance) ->
    @searchValue = new ReactiveVar()
    @index = new ReactiveVar 0
    @selectedItems = new ReactiveVar []
    @dropdownItems = new ReactiveVar []
    @showDropdown = new ReactiveVar false

  setShowDropdown: (value) ->
    check value, Boolean
    @showDropdown.set value

  getShowDropdown: ->
    thisContainer = $(@instance.firstNode)
    visible = @showDropdown.get()

    self = this
    checkForHide = (event) ->
      target = $(event.target)
      container = target.closest '.oafselect-container'
      return if container.is thisContainer
      self.setShowDropdown false

    if visible
      $(window).on 'click.oafselect', checkForHide
    else
      $(window).off 'click.oafselect'
    return visible

  getDropdownItems: ->
    searchValue = @getSearchValue()
    selected = @getSelectedItems()
    selectedIds = selected.map (item) -> item.value

    options = _.reject @instance.data.selectOptions, (option) ->
      option.value in selectedIds
    _.filter options, (option) ->
      return true unless searchValue?
      searchValueEscaped = searchValue.replace /[|\\{}()[\]^$+*?.]/g, '\\$&'
      regex = new RegExp searchValueEscaped, 'i'
      option.label.match regex

  getSelectedItems: ->
    @selectedItems.get()

  setSearchValue: (value) ->
    check value, String
    @setIndex 0
    @searchValue.set value
  getSearchValue: ->
    @searchValue.get()

  selectItem: (value) ->
    @setSearchValue ''
    items = @getFlatItems()

    current = @selectedItems.get()
    current = [] unless @instance.data.atts?.multiple
    for item in items when item.value is value
      current.push item

    @selectedItems.set current

  unselectItem: (value) ->
    items = @selectedItems.get()
    if value
      items = _.reject items, (item) -> item.value is value
    else
      items.pop()

    @selectedItems.set items

  getIndex: ->
    @index.get()

  setIndex: (value) ->
    items = @getFlatItems()
    if value+1 > items.length
      value = 0
    else if value < 0
      value = items.length - 1

    @index.set value

  getItemAtIndex: (index) ->
    items = @getFlatItems()
    return items[index]

  getFlatItems: ->
    newItems = []
    items = @getDropdownItems()

    items.forEach (root) ->
      if root.optgroup
        root.items.forEach (child) ->
          newItems.push _.extend child, optgroup: root.label
      else
        newItems.push root

    return newItems

  getItemIndex: (value) ->
    return index for item, index in @getFlatItems() when item.value is value

AutoForm.addInputType 'oafSelect',
  template: 'afOafSelect'
  valueOut: ->
    view = Blaze.getView @get(0)
    instance = view.templateInstance()
    atts = instance.data.atts

    selected = instance.oafSelect.getSelectedItems()

    if atts.multiple
      return selected.map (item) -> item.value
    else
      return _.first(selected)?.value
  valueConverters:
    'number': AutoForm.Utility.stringToNumber
    'numberArray': (val) ->
      if _.isArray(val)
        return _.map(val, (item) ->
          AutoForm.Utility.stringToNumber $.trim(item)
        )
      val
    'boolean': AutoForm.Utility.stringToBool
    'booleanArray': (val) ->
      if _.isArray(val)
        return _.map(val, (item) ->
          AutoForm.Utility.stringToBool $.trim(item)
        )
      val
    'date': AutoForm.Utility.stringToDate
    'dateArray': (val) ->
      if _.isArray(val)
        return _.map(val, (item) ->
          AutoForm.Utility.stringToDate $.trim(item)
        )
      val
  contextAdjust: (context) ->
    # build items list
    context.items = _.map(context.selectOptions, (opt) ->
      if opt.optgroup
        subItems = _.map(opt.options, (subOpt) ->
          {
            name: context.name
            label: subOpt.label
            value: subOpt.value
            htmlAtts: _.omit(subOpt, 'label', 'value')
            _id: subOpt.value
            selected: _.contains(context.value, subOpt.value)
            atts: context.atts
          }
        )
        {
          optgroup: opt.optgroup
          items: subItems
        }
      else
        {
          name: context.name
          label: opt.label
          value: opt.value
          htmlAtts: _.omit(opt, 'label', 'value')
          _id: opt.value
          selected: _.contains(context.value, opt.value)
          atts: context.atts
        }
    )
    return context

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
      index = template.oafSelect.getIndex()
      item = template.oafSelect.getItemAtIndex index
      return unless item?
      template.oafSelect.selectItem item.value

  'keyup input.oafselect-input': (event, template) ->
    return if event.keyCode in [9, 27, 38, 40]
    template.oafSelect.setSearchValue $(event.target).val()
  'focus input.oafselect-input': (event, template) ->
    template.oafSelect.setShowDropdown true
  'click .oafselect-input-wrapper': (event, template) ->
    template.$('input.oafselect-input').focus()

  'click .oafselect-selected-item .remove': (event, template) ->
    event.preventDefault()
    target = $(event.target).closest '.oafselect-selected-item'
    template.oafSelect.unselectItem target.attr('data-value')
  'click .oafselect-dropdown-item': (event, template) ->
    template.oafSelect.selectItem $(event.currentTarget).attr 'data-value'

Template.afOafSelect.helpers
  atts: ->
    _.omit @atts, 'oafSelectOptions'
  searchValue: ->
    instance = Template.instance()
    instance?.oafSelect.getSearchValue()
  options: ->
    options = _.clone @atts?.oafSelectOptions
    return unless options?
    options.create = true if options.create?
    return options
  dropdownItems: ->
    instance = Template.instance()
    instance?.oafSelect.getDropdownItems()
  selectedItems: ->
    instance = Template.instance()
    instance?.oafSelect.getSelectedItems()
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

Template.afOafSelect.onCreated ->
  @oafSelect = new OafSelect this
Template.afOafSelect.onRendered ->
Template.afOafSelect.onDestroyed ->
