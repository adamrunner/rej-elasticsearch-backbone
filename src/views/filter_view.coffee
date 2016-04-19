window.App ||= {}
class App.FilterView extends Backbone.View
  events:
    "change input.doFilter" : "doFilter"
  template: App.templates["filter"]

  initialize: (options) ->
    @listenTo Backbone, 'filters:created', @render
    @options    = options
    @filterType = @model.get('filterType')
    @queryValue = @model.get('key')
    @parentView = options.parentView
    @render()

  render: ->
    @$el.html(@template(@model.attributes))
    $("##{@filterType}").append(@$el)

  doFilter: (event) ->
    #TODO: Filtering should be handled higher up...

    @query = body: query:{}
    if event.target.checked
      @query.body.query["match"] = {}
      @query.body.query.match[@filterType] = @queryValue
      console.log("applying filter for #{@model.get('key')}")
    else
      @query.body.query["match_all"] = {}
      console.log("clearing filter for #{@model.get('key')}")
    # event.preventDefault()
    # @$el.addClass("active")


    Backbone.trigger('filters:change', @query)
