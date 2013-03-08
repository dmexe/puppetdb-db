window.App.ReportsCollection = Backbone.Collection.extend
  model: App.Report

  initialize: (models, options) ->
    @node = options.node
    @link = "#{@node.link}/reports"
    @name = "Reports"

  url: ->
    "/api/nodes/#{@node.name}/reports"

  comparator: (report) ->
    report.startAtTimestamp() * -1
