class App.FilterGroupView extends Backbone.View
  initialize: (options) ->
    @filterType = options.filterType
    @$el.prop('id', @filterType)
    @render()
  className: 'filter-group form-group col-xs-6 col-md-3'
  render: () ->
    @$el.html("<h4>#{S(@filterType).humanize().titleize()._wrapped}</h4>")
    $('#appForm').append(@$el)
