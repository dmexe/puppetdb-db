window.App.NodeView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node) ->
    @node = node
    @node.facts.once "sync", @render, @
    @node.facts.fetch()

  render: ->
    @html 'node/index', node: @node
