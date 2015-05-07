@OafSelect = class OafSelect
  constructor: (@instance) ->
    @searchValue = new ReactiveVar()
    @index = new ReactiveVar 0
    @selectedItems = new ReactiveVar []
    @showDropdown = new ReactiveVar false

  getCreateText: ->
    searchvalue = @getSearchValue()
    createText = @instance.data.atts.oafSelectOptions.createText
    return unless createText?
    return if searchvalue? and searchvalue is ''

    createText searchvalue

  createItem: ->
    searchvalue = @getSearchValue()
    create = @instance.data.atts.oafSelectOptions.create
    return unless create?
    return if searchvalue? and searchvalue is ''

    @setShowDropdown false

    callback = (val) =>
      @setSearchValue ''
      Meteor.setTimeout =>
        @selectItem val
      , 25

    value = create searchvalue, callback
    callback value if value?

  setShowDropdown: (value) ->
    check value, Boolean
    @showDropdown.set value

  getShowDropdown: ->
    thisContainer = $(@instance.firstNode)
    visible = @showDropdown.get()

    self = this
    checkForHide = (event) ->
      target = $(event.active)
      container = target.closest '.oafselect-container'
      return if container.is thisContainer
      self.setShowDropdown false

    return visible unless @instance.firstNode?

    BlurActive.remove @instance.$('input.oafselect-input'), 'oafselect'
    if visible
      BlurActive.add @instance.$('input.oafselect-input'),
        'oafselect',
        checkForHide

    return visible

  getDropdownItems: ->
    firstrun = !@firstrun?
    @firstrun = true

    @selectItem @instance.data.atts?.value if firstrun

    searchValue = @getSearchValue()
    selected = @getSelectedItems()
    selectedIds = selected.map (item) -> item.value

    # deep clone options
    options = _.values $.extend(true, {}, @instance.data.selectOptions)

    options = _.reject options, (option) ->
      if option.options?
        option.options = _.reject option.options, (sub) ->
          sub.value in selectedIds
        return option.options.length <= 0
      option.value in selectedIds

    searchOptions = (option) ->
      return true unless searchValue?
      return true if searchValue is ''
      searchValueEscaped = searchValue.replace /[|\\{}()[\]^$+*?.]/g, '\\$&'
      regex = new RegExp searchValueEscaped, 'i'
      if option.options?
        option.options = _.filter option.options, searchOptions
        return true if option.options.length > 0
      else if option.label?
        option.label.match regex

    _.filter options, searchOptions

  getSelectedItems: ->
    @selectedItems.get()

  setSearchValue: (value) ->
    check value, String
    @setIndex 0
    @searchValue.set value
  getSearchValue: ->
    @searchValue.get()

  selectItem: (value) ->
    return unless value?
    @setSearchValue ''
    items = @getFlatItems()

    current = @selectedItems.get()
    current = [] unless @instance.data.atts?.multiple
    for item in items when item.value is value
      current.push item
      @selectedItems.set current
      return $(@instance.firstNode).find('select').trigger 'change'

  unselectItem: (value) ->
    items = @selectedItems.get()
    if value
      items = _.reject items, (item) -> item.value is value
    else
      items.pop()

    @selectedItems.set items
    $(@instance.firstNode).find('select').trigger 'change'

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
      if root.options?
        root.options.forEach (child) ->
          newItems.push _.extend child, optgroup: root.label
      else
        newItems.push root

    return newItems

  getItemIndex: (value) ->
    return index for item, index in @getFlatItems() when item.value is value
