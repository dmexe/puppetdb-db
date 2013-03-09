window.App.FactsCollection = Backbone.Collection.extend
  model: App.Fact

  initialize: (models, options) ->
    @node = options.node

  url: ->
    "/api/nodes/#{@node.name}/facts"

  comparator: (fact) ->
    fact.name

  findByName: (name) ->
    @where(name: name)[0]
