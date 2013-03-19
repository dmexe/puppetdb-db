window.App.Router = Backbone.Router.extend

  routes:
    ""                         : "dashboard"
    "/"                        : "dashboard"
    "nodes/:node"              : "node"
    "nodes/:node/reports"      : "nodeReports"
    "nodes/:node/reports/:hash": "nodeReport"

  initialize:(options) ->
    @navView           = new App.NavView()
    @navView.activateDashboard()

    @searchView        = new App.SearchView
    @dashboardView     = new App.DashboardView
    @nodeView          = new App.NodeView
    @nodeReportsView   = new App.NodeReportsView
    @nodeReportView    = new App.NodeReportView

  dashboard: ->
    @navView.activateDashboard()
    @dashboardView.activate()

  node: (nodeName) ->
    node = new App.Node name: nodeName
    node.fetch().then =>
      @navView.activateNode node
      @nodeView.activate node

  nodeReports: (nodeName) ->
    node = new App.Node name: nodeName
    node.fetch().then =>
      @navView.activateNodeReports node
      @nodeReportsView.activate(node)

  nodeReport: (nodeName, hash) ->
    node = new App.Node name: nodeName
    node.fetch().then =>
      events = new App.EventsCollection [], node: node, hash: hash
      @navView.activateNodeReport node, hash
      @nodeReportView.activate(node, events)


