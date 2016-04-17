window.App ||= {}
class App.Product extends Backbone.Model

class App.Products extends Backbone.Collection
  model: App.Product

class App.Filter extends Backbone.Model

class App.Filters extends Backbone.Collection
  model: App.Filter
  initialize: ->
    @on "add", (model) ->
      # console.log("model added #{model.attributes.key}")
      Backbone.trigger('filters:created', model)
