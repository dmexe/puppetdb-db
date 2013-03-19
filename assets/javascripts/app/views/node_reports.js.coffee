window.App.NodeReportsView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    @statsView = new App.NodeReportsStatsView
    @reportsView = new App.NodeReportsReportsView

  activate: (node) ->
    @node = node
    @render()
    @node.reports.fetch().then @addReports.bind(@)
    @node.stats.fetch().then @addChart.bind(@)

  render: ->
    @html 'reports/index', node: @node

  addChart: ->
    @statsView.render(@node.stats)

  addReports: ->
    @reportsView.render(@node.reports).appendTo @el


App.NodeReportsStatsView = Backbone.View.extend
  render: (stats) ->
    el = $("#node-reports-stats-view")
    @chart = new App.SummaryChart(stats.forChart(), el.get(0))


App.NodeReportsReportsView = Backbone.View.extend
  id: "node-reports-reports-view"

  render: (reports) ->
    @html 'reports/reports', reports: reports
