window.App ||= {}
class App.FilterView extends Backbone.View
  events:
    "change input.doFilter" : "doFilter"
  template: App.templates["filter"]

  initialize: (options) ->
    @options    = options
    @filterType = @model.get('filterType')
    @queryValue = @model.get('key')
    @parentView = options.parentView
    @render()

  render: ->
    @$el.html(@template(@model.attributes))
    $("##{@filterType}").append(@$el)

  doFilter: (event) ->
    # @parentView.$el.find('.currentFilter').removeClass('currentFilter').prop('checked', false)
    # @$el.find('input').addClass('currentFilter')
    @query = {match: {}}
    @query["match"][@filterType] = @queryValue
    if event.target.checked
      Backbone.trigger('filters:add', @query)
    else
      Backbone.trigger('filters:remove', @query)
