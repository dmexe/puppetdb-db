window.App.DashboardView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    @nodes   = @options.nodes
    @metrics = new App.Metrics
    @metrics.on "sync", @addMetrics, @

  activate: ->
    $.when.apply(null, @nodes.map((i) -> i.reportsSummary.fetch() )).done =>
      @addSummary()
    @metrics.fetch()
    @render()

  render: ->
    @html 'dashboard/show', nodes: @nodes

  addMetrics: ->
    metrics = new App.MetricsView model: @metrics
    $(".table-nodes", $(@el)).before metrics.render().el

  addSummary: ->
    data = {}
    @nodes.each (it, n_idx) =>
      d = it.reportsSummary.forChart()
      data.days ||= d.days
      _.each data.days, (unused, idx) =>
        data.success       ||= []
        data.failed        ||= []
        data.requests      ||= []
        data.success[idx]  ||= 0
        data.failed[idx]   ||= 0
        data.requests[idx] ||= 0

        data.success[idx]  += d.success[idx]
        data.failed[idx]   += d.failed[idx]
        data.requests[idx] += d.success[idx] + d.failed[idx] + d.skipped[idx]
    chart = new App.SummaryChart(data, 'node-reports-summary-chart')

window.App.MetricsView = Backbone.View.extend
  tagName: "ul"
  className: "metrics inline well"

  initialize: ->
    @model = @options.model

  render: ->
    @html 'dashboard/metrics', metrics: @model
    @

