window.App ||= {}
class App.FilterView extends Backbone.View
  template: App.templates["filter"]
  initialize: (options) ->
    # @listenTo Backbone, 'filters:created', @render
    @options = options
    @render()
  render: ->
    # console.log(@model.attributes)
    $("#app").append(@template(@model.attributes))
