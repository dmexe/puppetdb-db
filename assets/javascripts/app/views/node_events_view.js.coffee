window.App.NodeEventsView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node, hash, nav) ->
    @node = node
    @node.reports.fetch().success =>
      @report = node.reports.findByHash(hash)
      @report.events.once "sync", @render, @
      @report.events.fetch()
      nav.render(node: @node, report: @report)

  render: ->
    @html 'events/index', report: @report
