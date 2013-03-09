window.App.NodeReportsView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node) ->
    @node      = node
    @node.reports.once        "sync", @render, @
    @node.reportsSummary.once "sync", @addSummary, @
    @node.reports.fetch()

  render: ->
    @html 'reports/index', node: @node
    @node.reports.each(@addOneReport)
    @node.reportsSummary.fetch()

  addOneReport: (report) =>
    view = new App.NodeReportView(model: report)
    $("table tbody", @el).append view.render().el

  addSummary: ->
    chart = new App.SummaryChart(@node.reportsSummary.forChart(), 'node-reports-summary-chart')
    @node.reports.each (report) =>
      sum = @node.reportsSummary.findByHash(report.hash)
      report.set("summary", sum)


window.App.NodeReportView = Backbone.View.extend
  tagName: "tr"

  initialize: ->
    @model.on "change", @render, @

  render: ->
    @html 'reports/row', report: @model
    @
