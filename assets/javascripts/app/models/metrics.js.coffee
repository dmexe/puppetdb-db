window.App.Metrics = Backbone.Model.extend
  initialize: ->

  url: ->
    '/api/metrics'

  numNodes: ->
    @get "num_nodes"

  numResources: ->
    @get "num_resources"

  avgResourcesPerNode: ->
    parseInt(@get "avg_resources_per_node")
