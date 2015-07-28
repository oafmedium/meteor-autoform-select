AutoForm.addInputType 'oafSelect',
  template: 'afOafSelect'
  valueOut: ->
    view = Blaze.getView @get(0)
    instance = view.templateInstance()
    atts = instance.data.atts

    selected = instance.oafSelect.getSelectedItems()

    if atts.multiple
      val = selected.map (item) -> item.value
    else
      val = _.first(selected)?.value

    val = "" unless val?
    return val
  valueConverters:
    'number': AutoForm.Utility.stringToNumber
    'numberArray': (val) ->
      if _.isArray(val)
        return val.map (item) -> AutoForm.Utility.stringToNumber $.trim(item)
      return val
    'boolean': AutoForm.Utility.stringToBool
    'booleanArray': (val) ->
      if _.isArray(val)
        return val.map (item) -> AutoForm.Utility.stringToBool $.trim(item)
      return val
    'date': AutoForm.Utility.stringToDate
    'dateArray': (val) ->
      if _.isArray(val)
        return map val.map (item) -> AutoForm.Utility.stringToDate $.trim(item)
      return val
  contextAdjust: (context) ->
    # build items list
    context.items = context.selectOptions?.map (opt) ->
      if opt.optgroup
        subItems = opt.options.map (subOpt) ->
          name: context.name
          label: subOpt.label
          value: subOpt.value
          htmlAtts: _.omit(subOpt, 'label', 'value')
          _id: subOpt.value
          selected: _.contains(context.value, subOpt.value)
          atts: context.atts
        optgroup: opt.optgroup
        items: subItems
      else
        name: context.name
        label: opt.label
        value: opt.value
        htmlAtts: _.omit(opt, 'label', 'value')
        _id: opt.value
        selected: _.contains(context.value, opt.value)
        atts: context.atts
    return context
