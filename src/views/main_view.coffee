class App.MainView extends Backbone.View
  template: App.templates["main_view"]
  initialize: (options) ->
    # @$el = options.el
    @listenTo Backbone, 'filters:created', @newFilterView
    @on('filters:changed', @applyFilter)
    @render()
  render: ->
    @$el.html(@template())
  newFilterView: (filterModel) ->
    # console.log("Creating new filter view for #{filterModel.attributes.key}")
    new App.FilterView({model: filterModel, parentView: @})

  newFilterGroupView: () ->
    console.log("creating new filter group view")
    new App.FilterGroupView()
