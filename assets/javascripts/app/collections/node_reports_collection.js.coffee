window.App.NodeReportsCollection = Backbone.Collection.extend
  model: App.Report

  initialize: (models, options) ->
    options ||= {}
    @node  = options.node
    @scope = options.scope
    if @node
      @link = "#{@node.link}/reports"
    else
      @link = '/'

  url: ->
    u = if @node
          "/api/nodes/#{@node.name}/reports"
        else
          "/api/reports"
    u = "#{u}?scope=#{@scope}" if @scope
    u

  findByHash: (hash) ->
    @where(hash: hash)[0]
