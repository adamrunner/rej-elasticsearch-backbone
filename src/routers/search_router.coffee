window.App ||= {}
client = new (elasticsearch.Client)(
  host: [
    'https://251a506566f18dc3000.qbox.io'
    'https://251a506566f18dc3001.qbox.io'
    'https://251a506566f18dc3002.qbox.io'
  ]
  log: 'trace'
)
categories = [
  new App.Category({title: "Pendants", category_fullpath: 'lighting_pendants'}),
  new App.Category({title: "Flush Mount Lighting", category_fullpath: 'lighting_flush-mounts'})
]
aggregations_query =
  'index': 'development-categories-products'
  'size': 0
  'type': 'product'
  'body':
    'query':
      'bool':
        'must': []
    'aggs':
      'product_type': 'terms': 'field': 'product_type'
      # 'category_fullpath' : 'terms' : 'field' : 'category_fullpath'

class App.SearchRouter extends Backbone.Router
  routes:
    "index"               : "index"
    "show/:category_path" : "showCategory"
    ".*"                  : "index"

  initialize: (options) ->
    window.productsCollection  = new App.Products
    @categoryViews = []
    @filterGroupViews = []
    @listenTo Backbone, 'router:go', @go
    @listenTo Backbone, 'filter_groups:build', @buildFilterGroups
    @listenTo Backbone, 'filters:build', @buildFilters
    @appView = new App.MainView(el: $("#app"))
    @searchControlsView = new App.SearchControlsView(el: $("#search_controls"))
    for category in categories
      @categoryViews.push new App.CategoryView(model: category)

  go: (route) ->
    # debugger
    return false if document.location.hash.slice(1) == route
    @cleanUpOldViews()
    @navigate route, trigger: yes

  index: () ->
    @query = 'match_all' : {}
    @getAggregations()
    @buildResultsView()

  showCategory: (category_path) ->
    @query = 'match': 'category_fullpath' : "#{category_path}"
    @getAggregations()
    @buildResultsView()

  cleanUpOldViews: () ->
    for filterGroupView in @filterGroupViews
      filterGroupView.remove()
    @resultsView.remove()

  buildResultsView: () ->
    @resultsView = new App.ResultsView({client: client, collection: productsCollection, query: @query})

  getAggregations: () ->
    aggregations_query.body.query.bool.must = [@query]
    aggregations = client.search(aggregations_query)
    aggregations.then (body) ->
      Backbone.trigger('filter_groups:build', body)

  buildFilterGroups: (body) ->
    window.filters = new App.Filters()
    for filterType, aggregation of body.aggregations
      @filterGroupViews.push new App.FilterGroupView({filterType: filterType})
      Backbone.trigger('filters:build', aggregation.buckets, filterType)

  buildFilters: (buckets, filterType) ->
    for bucket in buckets
      bucket.filterType = filterType
      window.filters.push( new App.Filter(bucket) )
