window.App.NodeView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node) ->
    @node  = node
    @facts = node.facts
    @facts.once "sync", @render, @
    @facts.fetch()

  render: ->
    @html 'node/index', node: @node
