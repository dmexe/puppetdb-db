window.App.DashboardView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    @nodes = @options.nodes

  activate: ->
    @render()

  render: ->
    @html 'dashboard/show', nodes: @nodes
