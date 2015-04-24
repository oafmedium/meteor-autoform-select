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
  'keyup input.oafselect-input': (event, template) ->
    template.searchValue.set $(event.target).val()
  'click .oafselect-dropdown-item': (event, template) ->
    current = template.selectedItems.get()
    current.push
      label: $(event.currentTarget).data 'label'
      value: $(event.currentTarget).data 'value'
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
    selected = instance?.selectedItems.get()
    selectedIds = selected.map (item) -> item.value

    options = _.reject @selectOptions, (option) -> option.value in selectedIds
    console.log selectedIds, options
    options
  selectedItems: ->
    instance = Template.instance()
    instance?.selectedItems.get()

Template.afOafSelect.onCreated ->
  @searchValue = new ReactiveVar()
  @selectedItems = new ReactiveVar([])
Template.afOafSelect.onRendered ->
Template.afOafSelect.onDestroyed ->
