class App.SearchControlsView extends Backbone.View
  events:
    'change #perPage' : "updatePageCount"
  template: App.templates['search_controls']

  initialize: (options) ->
    @perPage = 10
    @render()

  updatePageCount: () ->
    @perPage = parseInt(@$el.find('#perPage').val())
    Backbone.trigger('page_size:change', @perPage)
  render: () ->
    @$el.html(@template())
