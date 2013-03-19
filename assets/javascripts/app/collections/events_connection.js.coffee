window.App.EventsCollection = Backbone.Collection.extend
  model: App.Event

  initialize: (models, options) ->
    @node   = options.node
    @hash   = options.hash

  url: ->
    @node.url() + "/reports/#{@hash}"

  comparator: (event) ->
    event.timestamp * -1
