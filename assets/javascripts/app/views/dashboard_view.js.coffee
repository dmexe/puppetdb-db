window.App.DashboardView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    @nodes   = @options.nodes
    @stats   = new App.MonthlyStats
    @metrics = new App.Metrics
    @metrics.on "sync", @addMetrics, @
    @stats.on   "sync", @addStats, @

  activate: ->
    @metrics.fetch()
    @stats.fetch()
    @render()

  render: ->
    @html 'dashboard/show', nodes: @nodes

  addMetrics: ->
    metrics = new App.MetricsView model: @metrics
    $(".table-nodes", $(@el)).before metrics.render().el

  addStats: ->
    data = @stats.forChart()
    console.log(data)
    chart = new App.SummaryChart(data, 'node-reports-summary-chart')

window.App.MetricsView = Backbone.View.extend
  tagName: "ul"
  className: "metrics inline well"

  initialize: ->
    @model = @options.model

  render: ->
    @html 'dashboard/metrics', metrics: @model
    @

