App.DashboardView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    @stats       = new App.MonthlyStats
    @nodes       = new App.NodesCollection
    @reports     = new App.NodeReportsCollection
    @statsView   = new App.DashboardStatsView(model: @stats)
    @nodesView   = new App.DashboardNodesView(collection: @nodes)
    @reportsView = new App.DashboardReportsView(collection: @reports)
    @nodes.on   "sync", @addNodes,   @
    @stats.on   "sync", @addStats,   @
    @reports.on "sync", @addReports, @

  activate: ->
    @render()
    @stats.fetch()
    @nodes.fetch()
    @reports.fetch()

  render: ->
    @html 'dashboard/show'

  addStats: ->
    @statsView.render()

  addNodes: ->
    @nodesView.render().appendTo $(".pill-content", @el)
    @toggleTab()

  addReports: ->
    @reportsView.render().appendTo $(".pill-content", @el)
    @toggleTab()

  toggleTab: ->
    id = $(".pill-content .active", @el).attr("id")
    $(".nav a[href=##{id}]", @el).click()


App.DashboardStatsView = Backbone.View.extend
  render: ->
    el = $("#dashboard-stats-view")
    @chart = new App.SummaryChart(@model.forChart(), el.get(0))

App.DashboardNodesView = Backbone.View.extend
  id: "dashboard-nodes-view"
  className: "pill-pane active"

  render: ->
    @html "dashboard/nodes", nodes: @collection

App.DashboardReportsView = Backbone.View.extend
  id: "dashboard-reports-view"
  className: "pill-pane"

  render: ->
    @html "dashboard/reports", reports: @collection
