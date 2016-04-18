class App.FilterGroupView extends Backbone.View
  # template: App.templates['filter_group']
  initialize: (options) ->
    @filterType = options.filterType
    @$el.prop('id', @filterType)
    @render()
  className: 'filter-group col-xs-6 col-md-3'
  render: () ->
    @$el.html("<h4>#{S(@filterType).humanize().titleize()._wrapped}</h4>")
    $('#app').append(@$el)
