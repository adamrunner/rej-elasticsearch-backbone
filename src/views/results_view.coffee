class App.ResultsView extends Backbone.View
  id: "resultView"
  className: "row"
  blank_template: App.templates["blank_results"]
  initialize: (options) ->
    @listenTo(@collection, 'reset', @render)
    @listenTo(Backbone, 'filters:add', @addFilter)
    @listenTo(Backbone, 'filters:remove', @removeFilter)
    @listenTo(Backbone, 'page_size:change', @changePageSize)
    @listenTo(Backbone, 'page:change', @changePage)
    @perPage     = options.perPage || 12
    @currentPage = options.currentPage || 1
    @fromCount   = (@currentPage * @perPage) - @perPage
    @originalQuery = options.query
    @currentQuery ||=
      'index': 'development-categories-products'
      'size': @perPage
      'type': 'product'
      'body':
        'sort': 'sort_order' : 'asc'
        'query': 'match_all' : {}
        'filter':
          'bool':
            'must': [@originalQuery]
            'should': []
    @client = options.client
    @doSearch()

  changePageSize: (page_size) ->
    @perPage           = page_size
    @currentQuery.size = @perPage
    @updateFromCount()
    @doSearch()

  updateFromCount: () ->
    @fromCount         = (@currentPage * @perPage) - @perPage
    @currentQuery.from = @fromCount

  changePage: (page) ->
    @currentPage = page
    @updateFromCount()
    @doSearch()

  triggerPageEvent: () ->
    Backbone.trigger('page:enable')

    if @currentPage == 1
      console.log('first page')
      Backbone.trigger('page:first')

    if (@currentPage * @perPage) > @maxResults
      console.log('last page')
      Backbone.trigger('page:last')

  doSearch: () ->
    @client.search(@currentQuery).then (results) =>
      @results = results.hits.hits
      @maxResults = results.hits.total
      productAttributes = @results.map (result) =>
        _.extend(result._source, { id: result._id})
        result._source
      @collection.reset productAttributes
      @triggerPageEvent()
  removeFilter: (filter) ->
    @currentPage = 1
    @updateFromCount()
    shouldArray = @currentQuery.body.filter.bool.should
    newShouldArray = _.reject(shouldArray, (shouldObject) =>
      _.isMatch(shouldObject.term, filter.term)
    )
    @currentQuery.body.filter.bool.should = newShouldArray
    @doSearch()

  addFilter: (filter) ->
    @currentPage = 1
    @updateFromCount()
    @currentQuery.body.filter.bool.should.push filter
    @doSearch()

  render: () ->
    if @collection.length > 0
      new App.ResultsSummaryView({perPage: @perPage, fromCount: @fromCount, currentPage: @currentPage, maxResults: @maxResults, el: $("#countSummary")})
      productViews = @collection.map (product) =>
        new App.ProductView(model:product).$el

      @$el.html(productViews)

    else
      @$el.html(@blank_template())
      $("#countSummary").html('')
    $("#products").html(@$el)
    @
