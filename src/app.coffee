client = new (elasticsearch.Client)(
  host: [
    'https://251a506566f18dc3000.qbox.io'
    'https://251a506566f18dc3001.qbox.io'
    'https://251a506566f18dc3002.qbox.io'
  ]
  log: 'trace')

aggregations = client.search(
  'index': 'development-categories-products'
  'size': 0
  'body': 'aggs':
    'class': 'terms': 'field': 'product_class'
    'supercat': 'terms': 'field': 'supercat'
    'category': 'terms': 'field': 'category'
    'product_type': 'terms': 'field': 'product_type'
    'always_free_to_ship': 'terms': 'field': 'always_free_to_ship')


$ ->
  appView = new App.MainView
  aggregations.then (body) =>
    window.filters = new App.Filters
    for key, value of body.aggregations
      for bucket in value.buckets
        bucket.filter_type = key
        # console.log("#{key} #{bucket.key}")
        window.filters.push( new App.Filter(bucket) )
  # window.filters.each (filter) ->
  #   new App.FilterView({model: filter})
      # new App.FilterView({title: key, buckets: value.buckets})
