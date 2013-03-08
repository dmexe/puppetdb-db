window.App.NodesCollection = Backbone.Collection.extend
  model: App.Node

  url: '/api/nodes'

  comparator: (node) ->
    node.reportAtTimestamp() * -1

  findByName: (name) ->
    @where(name: name)[0]
