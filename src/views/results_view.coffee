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
    @perPage     = options.perPage || 10
    @currentPage = options.currentPage || 1
    @fromCount   = (@currentPage * @perPage) - @perPage
    @originalQuery = options.query
    @currentQuery ||=
      'index': 'development-categories-products'
      'size': @perPage
      'type': 'product'
      'body':
        'sort': 'sort_order' : 'asc'
        'query':
          'bool':
            'must': [@originalQuery]
    @client = options.client
    @doSearch()

  clearFilters: () ->
    @currentQuery =
      'index': 'development-categories-products'
      'size': @perPage
      'type': 'product'
      'body':
        'query':
          'bool':
            'must': [@originalQuery]
    @doSearch()

  changePageSize: (page_size) ->
    @perPage           = page_size
    @currentQuery.size = @perPage
    @doSearch()

  changePage: (page) ->
    @currentPage       = page
    @fromCount         = (page * @perPage) - @perPage
    @currentQuery.from = @fromCount
    @doSearch()

  triggerPageEvent: () ->
    if @currentPage == 1
      Backbone.trigger('page:first')
    if @currentPage * @perPage > @maxResults
      Backbone.trigger('page:last')

  doSearch: () ->
    @triggerPageEvent()
    # _.extend( @currentQuery, query )
    @client.search(@currentQuery).then (results) =>
      @results = results.hits.hits
      @maxResults = results.hits.total
      productAttributes = @results.map (result) =>
        _.extend(result._source, { id: result._id})
        result._source
      @collection.reset productAttributes

  removeFilter: (filter) ->
    @currentQuery.body.query.bool.must = [@originalQuery]
    @doSearch()

  addFilter: (filter) ->
    console.log("Adding filter")
    console.log(filter)
    @currentQuery.body.query.bool.must.push filter
    console.log("query result")
    console.log(@currentQuery)
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
