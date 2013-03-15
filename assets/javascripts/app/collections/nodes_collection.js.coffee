window.App.NodesCollection = Backbone.Collection.extend
  model: App.Node

  url: '/api/nodes'

  findByName: (name) ->
    @where(name: name)[0]
