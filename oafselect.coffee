@OafSelect = class OafSelect
  constructor: (@instance) ->
    @searchValue = new ReactiveVar()
    @index = new ReactiveVar 0
    @selectedItems = new ReactiveVar []
    @showDropdown = new ReactiveVar false
    @instanceId = "oafselect-#{Meteor.uuid()}"

    firstrun = !@firstrun?
    @firstrun = true

    if firstrun
      val = @instance.data.value
      values = if val instanceof Array then val else [val]
      @selectItem value for value in values

  getControls: ->
    container: @instance.$('div.oafselect-container')
    inputWrapper: @instance.$('.oafselect-input-wrapper')
    selectedItems: @instance.$('.oafselect-selected-item')
    input: @instance.$('.oafselect-input')
    dropdown: @instance.$('.oafselect-dropdown')
    dropdownGroups: @instance.$('.oafselect-dropdown-group')
    dropdownItems: @instance.$('.oafselect-dropdown-item')

  getOptions: ->
    @instance.data.atts.oafSelectOptions or {}

  getAtts: ->
    atts = _.omit @instance.data.atts, 'oafSelectOptions'
    atts = AutoForm.Utility.addClass atts, 'oafselect-container'
    return atts

  getCreateText: ->
    searchvalue = @getSearchValue()
    createText = @getOptions().createText
    return unless createText?
    return unless searchvalue?
    return if searchvalue is ''

    createText.call @, searchvalue

  createItem: (viewCallback) ->
    searchvalue = @getSearchValue()
    create = @getOptions().create
    return unless create?
    return unless searchvalue?
    return if searchvalue is ''

    @setShowDropdown false

    callback = (val) =>
      @setSearchValue ''
      Meteor.setTimeout =>
        @selectItem val
        viewCallback() if viewCallback?
      , 150

    value = create.call @, searchvalue, callback
    callback value if value?

  setShowDropdown: (value) ->
    check value, Boolean
    return if @showDropdown.get() is value
    if value and not @getAtts().multiple
      @unselectItem()

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

    BlurActive.remove @instance.$('input.oafselect-input'), @instanceId
    if visible
      BlurActive.add @instance.$('input.oafselect-input'),
        @instanceId,
        checkForHide

    return visible

  getDropdownItems: ->
    searchValue = @getSearchValue()
    selected = @getSelectedItems()
    selectedIds = selected.map (item) -> item.value

    if @getOptions().autocomplete?
      showall = false
      if @getOptions().autocompleteShowAll?
        if typeof @getOptions().autocompleteShowAll is 'function'
          showall = @getOptions().autocompleteShowAll()
        else
          showall = @getOptions().autocompleteShowAll

      return [] unless (searchValue? and searchValue isnt '') or showall
      # return [] unless searchValue? and searchValue isnt ''

      if not showall and @getOptions().autocompleteStartLimit?
        return [] if searchValue.length < @getOptions().autocompleteStartLimit
      options = @getOptions().autocomplete searchValue
    else
      # deep clone options
      options = _.values $.extend(true, {}, @instance.data.selectOptions)

    options = _.reject options, (option) ->
      if option.options?
        option.options = _.reject option.options, (sub) ->
          sub.value in selectedIds
        return option.options.length <= 0
      option.value in selectedIds

    unless @getOptions().autocomplete?
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
      options = _.filter options, searchOptions

    if @getOptions().limitItems > 0
      count = 0
      limit = @getOptions().limitItems
      limitOptions = (option) ->
        overlimit = false
        overlimit = true if count+1 > limit
        count++

        if option.options?
          count--
          option.options = _.filter option.options, limitOptions
        return !overlimit
      options = _.filter options, limitOptions
    return @addIndexToOptions options

  addIndexToOptions: (options) ->
    index = 0
    options.map (opt) ->
      opt._index = index++
      return opt

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
    return if value is ''

    @setSearchValue ''
    items = @getFlatItems true

    current = @selectedItems.get()
    current = [] unless @instance.data.atts?.multiple
    for item in items when item.value is value
      current.push item
      @selectedItems.set current
      if not @getAtts().multiple or @getOptions().autoclose
        @setShowDropdown false
      return $(@instance.firstNode).find('select').trigger 'change'

  unselectItem: (value) ->
    items = @selectedItems.get()
    return unless items.length > 0
    if value?
      items = _.reject items, (item) -> item.value is value
    else
      items.pop()

    @selectedItems.set items
    $(@instance.firstNode).find('select').trigger 'change'

  getIndex: ->
    @index.get()

  setIndex: (value) ->
    additional = 0
    additional++ unless @getCreateText()?

    items = @getFlatItems()
    if (value + additional) > items.length
      value = 0
    else if value < 0
      value = (items.length - additional)

    @index.set value

  getItemAtIndex: (index) ->
    items = @getFlatItems()
    return items[index]

  getFlatItems: (all) ->
    newItems = []
    if all
      if @getOptions().autocomplete?
        items = @getOptions().autocomplete()
      else
        items = @instance.data.selectOptions or []
    else
      items = @getDropdownItems()

    items.forEach (root) ->
      if root.options?
        root.options.forEach (child) ->
          newItems.push _.extend child, optgroup: root.label
      else
        newItems.push root

    return @addIndexToOptions newItems
