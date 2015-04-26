AutoForm.addInputType 'oafSelect',
  template: 'afOafSelect'
  valueOut: ->
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
    context

Template.afOafSelect.events
  'keydown input.oafselect-input': (event, template) ->
    if event.keyCode in [9, 27]
      template.showDropdown.set false

    if event.keyCode is 8 and $(event.target).val() is ''
      items = template.selectedItems.get()
      items.pop()
      template.selectedItems.set items

  'keyup input.oafselect-input': (event, template) ->
    template.searchValue.set $(event.target).val()
  'focus input.oafselect-input': (event, template) ->
    template.showDropdown.set true
  'click .oafselect-input-wrapper': (event, template) ->
    template.$('input.oafselect-input').focus()

  'click .oafselect-selected-item .remove': (event, template) ->
    event.preventDefault()
    target = $(event.target).closest '.oafselect-selected-item'

    items = template.selectedItems.get()
    template.selectedItems.set _.reject items, (item) ->
      item.value is target.attr('data-value')
  'click .oafselect-dropdown-item': (event, template) ->
    current = template.selectedItems.get()
    atts = template.data.atts
    current = [] unless atts.multiple
    current.push
      label: $(event.currentTarget).attr 'data-label'
      value: $(event.currentTarget).attr 'data-value'
    template.selectedItems.set current

Template.afOafSelect.helpers
  atts: ->
    atts = _.clone @atts
    delete atts.oafSelectOptions

    return atts
  searchValue: ->
    instance = Template.instance()
    instance?.searchValue.get()
  options: ->
    options = _.clone @atts?.oafSelectOptions
    return unless options?
    options.create = true if options.create?
    return options
  dropdownItems: ->
    instance = Template.instance()
    return unless instance?

    searchValue = instance.searchValue.get()
    selected = instance.selectedItems.get()
    selectedIds = selected.map (item) -> item.value

    options = _.reject @selectOptions, (option) -> option.value in selectedIds
    _.filter options, (option) ->
      return true unless searchValue?
      searchValueEscaped = searchValue.replace /[|\\{}()[\]^$+*?.]/g, '\\$&'
      regex = new RegExp searchValueEscaped, 'i'
      option.label.match regex
  selectedItems: ->
    instance = Template.instance()
    instance?.selectedItems.get()
  showDropdown: ->
    instance = Template.instance()
    thisContainer = $(instance.firstNode)

    visible = instance?.showDropdown.get()

    checkForHide = (event) ->
      target = $(event.target)
      container = target.closest '.oafselect-container'
      return if container.is thisContainer
      instance.showDropdown.set false

    if visible
      $(window).on 'click.oafselect', checkForHide
    else
      $(window).off 'click.oafselect'
    return visible

Template.afOafSelect.onCreated ->
  @searchValue = new ReactiveVar()
  @selectedItems = new ReactiveVar []
  @showDropdown = new ReactiveVar false
Template.afOafSelect.onRendered ->
Template.afOafSelect.onDestroyed ->
