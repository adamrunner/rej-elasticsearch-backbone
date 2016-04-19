class App.SearchView extends Backbone.View
  id: "searchResults"
  className: "row"
  template: App.templates["search_summary"]
  initialize: (options) ->
    @listenTo(@collection, 'reset', @render)
    @listenTo(Backbone, 'filters:change', @doSearch)
    @listenTo(Backbone, 'filters:clear', @clearFilters)
    @currentQuery =
      'index': 'development-categories-products'
      'size': 10
    @client = options.client
    @doSearch()

  clearFilters: () ->
    @currentQuery =
      'index': 'development-categories-products'
      'size': 10
    @doSearch()

  doSearch: (query) ->
    _.extend( @currentQuery, query )
    @client.search(@currentQuery).then (results) =>
      @results = results.hits.hits
      @maxResults = results.hits.total
      productAttributes = @results.map (result) =>
        _.extend(result._source, { id: result._id})
        result._source
      @collection.reset productAttributes

  render: () ->
    productViews = @collection.map (product) =>
      new App.ProductView(model:product).$el

    @$el.html(productViews)

    $("#app").after(@$el)
    @
