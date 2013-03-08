window.App.NodeReportsView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node) ->
    @node = node
    @node.reports.once "sync", @render, @
    @node.reports.fetch()

  render: ->
    @html 'reports/index', node: @node
