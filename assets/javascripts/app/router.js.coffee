window.App.Router = Backbone.Router.extend

  routes:
    ""                         : "dashboard"
    "/"                        : "dashboard"
    "nodes/:node"              : "node"
    "nodes/:node/reports"      : "nodeReports"
    "nodes/:node/reports/:hash": "nodeEvents"
    "query/*q"                 : "query"

  initialize:(options) ->
    @nodes      = options.nodes
    @navView    = new App.NavView()
    @navView.render()

    @searchView        = new App.SearchView
    @dashboardView     = new App.DashboardView(nodes: @nodes)
    @nodeView          = new App.NodeView()
    @nodeReportsView   = new App.NodeReportsView()
    @nodeEventsView    = new App.NodeEventsView()

  dashboard: ->
    @navView.render()
    @dashboardView.activate()

  node: (nodeName) ->
    node = @nodes.findByName(nodeName)
    @navView.render(node: node)
    @nodeView.activate(node)

  nodeReports: (nodeName) ->
    node = @nodes.findByName(nodeName)
    @navView.render(node: node, reports: true)
    @nodeReportsView.activate(node)

  nodeEvents: (nodeName, hash) ->
    node = @nodes.findByName(nodeName)
    @nodeEventsView.activate(node, hash, @navView)

  query: (q) ->
    console.log q
    @navView.render query: q
    @searchView.activate(q)


$(document).ready ->
  unless window.jasmine
    nodes = new App.NodesCollection()
    nodes.fetch().success ->
      window.appRouter = new App.Router(nodes: nodes)
      Backbone.history.start(pushState: true, root: "/ui/")

    $("body").on "click", "a", (ev) ->
      el = $(ev.currentTarget)
      window.appRouter.navigate(el.attr("href"), trigger: true)
      false
