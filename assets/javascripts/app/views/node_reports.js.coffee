window.App.NodeReportsView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node) ->
    @node  = node
    @stats = new App.NodeMonthlyStats({}, {node: @node})
    @node.reports.once        "sync", @render, @
    @stats.once               "sync", @addChart, @
    @node.reports.fetch()

  render: ->
    @html 'reports/index', node: @node
    @node.reports.each(@addOneReport)
    @stats.fetch()

  addOneReport: (report) =>
    view = new App.NodeReportView(model: report)
    $("table tbody", @el).append view.render().el

  addChart: ->
    new App.SummaryChart(@stats.forChart(), 'node-reports-summary-chart')

window.App.NodeReportView = Backbone.View.extend
  tagName: "tr"

  initialize: ->
    @model.on "change", @render, @

  render: ->
    @html 'reports/row', report: @model
    @
