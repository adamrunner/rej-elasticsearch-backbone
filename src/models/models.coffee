window.App ||= {}
class App.Product extends Backbone.Model

class App.Products extends Backbone.Collection
  model: App.Product

class App.Filter extends Backbone.Model

class App.Filters extends Backbone.Collection
  model: App.Filter
  initialize: ->
    @on "add", (model) ->
      # console.log("filter added #{model.attributes.key}")
      Backbone.trigger('filters:created', model)

class App.Category extends Backbone.Model
  initialize: (options) ->
    @set('showUrl', "show/#{@get('slug')}")

class App.Categories extends Backbone.Collection
  model: App.Category
