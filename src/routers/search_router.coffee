window.App ||= {}
client = new (elasticsearch.Client)(
  host: [
    'https://251a506566f18dc3000.qbox.io'
    'https://251a506566f18dc3001.qbox.io'
    'https://251a506566f18dc3002.qbox.io'
  ]
  log: 'trace'
)
# window.index_name = 'categories-nested-products'
window.index_name = 'development-products-categories'
categories = [
  new App.Category({title: "Pendants", category_id: '573bfd6fbe8a5c7232001ab3', slug:"pendants" }),
  new App.Category({title: "Flush Mount Lighting", category_id: '573bfd6fbe8a5c7232001ab5', slug:"flush-mount-lighting" })
  new App.Category({title: "Chandeliers", category_id: '573bfd6fbe8a5c7232001ab7', slug:"chandeliers" })
  new App.Category({title: "Wall Sconces", category_id: '573bfd6fbe8a5c7232001ab9', slug:"wall-sconces"})
]
categoriesCollection = new App.Categories(categories)

aggregations_query =
  'index': window.index_name
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
    @listenTo Backbone, 'page_size:change', @storePageSize
    @pageSize = 12
    @appView            = new App.MainView(el          : $("#app"))
    @searchControlsView = new App.SearchControlsView(el: $("#searchControls"))
    @paginationView     = new App.PaginationView(el    : $("#pagination"))
    for category in categories
      @categoryViews.push new App.CategoryView(model: category)

  storePageSize: (pageSize) ->
    @pageSize = pageSize

  go: (route) ->
    # debugger
    return false if document.location.hash.slice(1) == route
    @cleanUpOldViews()
    @navigate route, trigger: yes

  index: () ->
    @query = 'match_all' : {}
    @getAggregations()
    @buildResultsView()

  showCategory: (slug) ->
    category = categoriesCollection.where(slug: slug)[0]
    @query = 'term': 'category_ids' : category.get('category_id')
    @getAggregations()
    @buildResultsView()

  cleanUpOldViews: () ->
    for filterGroupView in @filterGroupViews
      filterGroupView.remove()
    @resultsView.remove()

  buildResultsView: () ->
    @resultsView = new App.ResultsView({client: client, collection: productsCollection, query: @query, perPage: @pageSize})

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
