class App.ResultsSummaryView extends Backbone.View
  template: App.templates['search_summary']
  initialize: (options) ->
    @results = options.results
    @maxResults = options.maxResults
    @render()

  render: () ->
    @$el.html(@template({results: @results, maxResults: @maxResults}))
