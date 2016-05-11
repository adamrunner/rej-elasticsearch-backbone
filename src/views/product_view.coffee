class App.ProductView extends Backbone.View
  template: App.templates["product"]
  className: 'product col-xs-6 col-md-3'
  initialize: (options) ->
    @render()
  render: () ->
    @$el.html(@template(@model.attributes))
    @
