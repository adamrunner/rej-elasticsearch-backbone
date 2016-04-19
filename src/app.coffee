client = new (elasticsearch.Client)(
  host: [
    'https://251a506566f18dc3000.qbox.io'
    'https://251a506566f18dc3001.qbox.io'
    'https://251a506566f18dc3002.qbox.io'
  ]
  log: 'trace'
  )

aggregations = client.search(
  'index': 'development-categories-products'
  'size': 0
  'body': 'aggs':
    'product_class': 'terms': 'field': 'product_class'
    'categories' : 'terms' : 'field' : 'categories'
    'supercat': 'terms': 'field': 'supercat'
    'category': 'terms': 'field': 'category'
    'product_type': 'terms': 'field': 'product_type'
    'always_free_to_ship': 'terms': 'field': 'always_free_to_ship')


$ ->
  appView = new App.MainView
  window.productsCollection = new App.Products
  searchView = new App.SearchView({client: client, collection: productsCollection})
  searchControlsView = new App.SearchControlsView
  window.filters = new App.Filters()
  aggregations.then (body) =>
    for filterType, aggregation of body.aggregations
      new App.FilterGroupView({filterType: filterType})
      for bucket in aggregation.buckets
        bucket.filterType = filterType
        window.filters.push( new App.Filter(bucket) )
