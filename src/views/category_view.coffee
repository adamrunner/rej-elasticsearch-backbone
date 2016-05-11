class App.CategoryView extends Backbone.View
  tagName: 'li'
  events:
    'click a' : 'chooseCategory'
  template: App.templates['category']

  initialize: (options) ->
    @render()

  render: () ->
    @$el.html(@template(@model.attributes))
    $("#categories").append(@$el)

  chooseCategory: (event) ->
    event.preventDefault()
    Backbone.trigger 'router:go', @model.get('showUrl')
