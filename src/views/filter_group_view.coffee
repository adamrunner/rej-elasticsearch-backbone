class App.FilterGroupView extends Backbone.View
  initialize: (options) ->
    @filterType = options.filterType
    @parentView = options.parentView
    @$el.prop('id', @filterType)
    @render()
  # className: 'filter-group'
  render: () ->
    @$el.html("<h4>#{S(@filterType).humanize().titleize()._wrapped}</h4>")
    $("#filterGroups").append(@$el)
