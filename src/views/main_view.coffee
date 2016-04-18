class App.MainView extends Backbone.View
  initialize: ->
    @listenTo Backbone, 'filters:created', @newFilterView
    # @listenTo Backbone, 'filter_group:created', @newFilterGroupView
  newFilterView: (filterModel) ->
    console.log("Creating new filter view for #{filterModel.attributes.key}")
    new App.FilterView({model: filterModel})

  newFilterGroupView: () ->
    console.log("creating new filter group view")
    new App.FilterGroupView()
