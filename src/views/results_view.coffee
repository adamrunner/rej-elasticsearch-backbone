class App.ResultsView extends Backbone.View
  id: "resultView"
  className: "row"
  template: App.templates["search_summary"]
  initialize: (options) ->
    @listenTo(@collection, 'reset', @render)
    @listenTo(Backbone, 'filters:add', @addFilter)
    @listenTo(Backbone, 'filters:remove', @removeFilter)
    @listenTo(Backbone, 'page_size:change', @changePageSize)
    @perPage = options.perPage || 10
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
    @currentQuery.size = page_size
    @doSearch()

  doSearch: () ->
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
    productViews = @collection.map (product) =>
      new App.ProductView(model:product).$el

    @$el.html(productViews)

    $("#products").html(@$el)
    new App.ResultsSummaryView({results: @results.hits.hits.length, total: @maxResults, el: $("#countSummary")})
    @
