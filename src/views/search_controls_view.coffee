class App.SearchControlsView extends Backbone.View
  events:
    'change #perPage' : "updateResults"
    'click #clearFilters' : "clearFilters"
  template: App.templates['search_controls']
  className: 'col-xs-12'

  initialize: (options) ->
    @query = {}
    @render()

  updateResults: ->
    @updateQuery()
    Backbone.trigger('filters:change', @query)

  updateQuery: () ->
    perPage = @$el.find('#perPage').val()
    @query = {size: perPage}

  clearFilters: () ->
    Backbone.trigger('filters:clear')
    @$el.html(@template())

  render: () ->
    @$el.html(@template())
    $("#app").append(@$el)
