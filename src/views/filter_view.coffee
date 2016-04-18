window.App ||= {}
class App.FilterView extends Backbone.View
  events:
    "click a.applyFilter" : "applyFilter"
  template: App.templates["filter"]

  initialize: (options) ->
    @listenTo Backbone, 'filters:created', @render
    @options    = options
    @filterType = @model.get('filterType')
    @queryValue = @model.get('key')
    @render()

  render: ->
    @$el.html(@template(@model.attributes))
    $("##{@filterType}").append(@$el)

  applyFilter: (event) ->
    event.preventDefault()
    # @$el.addClass("active")
    @query = body: query:{ match:{}}
    @query.body.query.match[@filterType] = @queryValue
    Backbone.trigger('filters:change', @query)
    console.log("applying filter for #{@model.get('key')}")
