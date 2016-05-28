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
# categories = [
#   new App.Category({title: "Pendants", category_id: '57489773be8a5c06c3000003', slug:"pendants" }),
#   new App.Category({title: "Flush Mount Lighting", category_id: '57489783be8a5c06c3000005', slug:"flush-mount-lighting" })
#   new App.Category({title: "Chandeliers", category_id: '574897bebe8a5c06c3000007', slug:"chandeliers" })
#   new App.Category({title: "Wall Sconces", category_id: '574897cabe8a5c06c3000009', slug:"wall-sconces"})
# ]

categories = [{"title":"Pendants","slug":"pendants","category_id":"57489773be8a5c06c3000003"},{"title":"Flush Mount Lighting","slug":"flush-mount-lighting","category_id":"57489783be8a5c06c3000005"},{"title":"Chandeliers","slug":"chandeliers","category_id":"574897bebe8a5c06c3000007"},{"title":"Wall Sconces","slug":"wall-sconces","category_id":"574897cabe8a5c06c3000009"},{"title":"String Lights","slug":"string-lights","category_id":"57462758be8a5cb7850002b9"},{"title":"Table \u0026 Desk Lamps","slug":"table-\u0026-desk-lamps","category_id":"5749d6c2be8a5c06c300020a"},{"title":"Floor Lamps","slug":"floor-lamps","category_id":"5749d6d1be8a5c06c300020c"},{"title":"Pin-Ups \u0026 Plug-Ins","slug":"pin-ups-\u0026-plug-ins","category_id":"5749d6e1be8a5c06c300020e"}]
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
      'finish' : 'terms' : 'field' : 'finish'
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
    categoriesCollection.each (category) =>
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
      if aggregation.buckets.length > 0
        @filterGroupViews.push new App.FilterGroupView({filterType: filterType})
        Backbone.trigger('filters:build', aggregation.buckets, filterType)

  buildFilters: (buckets, filterType) ->
    for bucket in buckets
      bucket.filterType = filterType
      window.filters.push( new App.Filter(bucket) )
