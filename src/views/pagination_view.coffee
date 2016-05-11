class App.PaginationView extends Backbone.View
  template: App.templates["pagination"]
  events:
    'click #nextPage' : 'nextPage'
    'click #prevPage' : 'prevPage'
  initialize: (options) ->
    @listenTo(Backbone, 'page:first', @disablePrev)
    @listenTo(Backbone, 'page:last', @disableNext)
    @listenTo(Backbone, 'page:change', @enableControls)
    @currentPage = options.currentPage || 1
    @render()
    @disablePrev() if @currentPage == 1

  nextPage: (event) ->
    event.preventDefault()
    @currentPage = @currentPage + 1
    @changePage()

  prevPage: (event) ->
    event.preventDefault()
    @currentPage = @currentPage - 1
    @changePage()

  changePage: () ->
    Backbone.trigger('page:change', @currentPage)

  enableControls: () ->
    @$el.find('.disabled').removeClass('disabled')

  disablePrev: () ->
    @$el.find('#prevPage').parent('li').addClass('disabled')

  disableNext: () ->
    @$el.find('#nextPage').parent('li').addClass('disabled')
  render: () ->
    @$el.html(@template({currentPage: @currentPage}))
