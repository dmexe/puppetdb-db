window.App.DashboardView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    @nodes = @options.nodes

  activate: ->
    $.when.apply(null, @nodes.map((i) -> i.reportsSummary.fetch() )).done =>
      @addSummary()
    @render()

  render: ->
    @html 'dashboard/show', nodes: @nodes

  addSummary: ->
    data = {}
    @nodes.each (it, n_idx) =>
      d = it.reportsSummary.forChart()
      data.days ||= d.days
      _.each data.days, (unused, idx) =>
        data.success       ||= []
        data.failed        ||= []
        data.success[idx]  ||= 0
        data.failed[idx]   ||= 0

        data.success[idx]  += d.success[idx]
        data.failed[idx]   += d.failed[idx]
    console.log data
    chart = new App.SummaryChart(data, 'node-reports-summary-chart')



