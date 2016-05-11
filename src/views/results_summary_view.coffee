class App.ResultsSummaryView extends Backbone.View
  template: App.templates['search_summary']
  initialize: (options) ->
    @perPage     = options.perPage
    @maxResults  = options.maxResults
    @currentPage = options.currentPage
    @toCount     = options.fromCount + @perPage
    if options.fromCount > 0
      @fromCount = options.fromCount
    else
      @fromCount = 1

    @render()

  render: () ->
    @$el.html(@template({fromCount: @fromCount, toCount: @toCount, maxResults: @maxResults}))
