window.App.Node = Backbone.Model.extend
  initialize: ->
    @name     = @get("name")
    @link     = "/nodes/#{@name}"
    @facts    = new App.FactsCollection([], node: @)
    @reports  = new App.NodeReportsCollection([], node: @)
    @stats    = new App.NodeMonthlyStats({}, {node: @})

  reportAt: ->
    moment(@get "report_timestamp")

  fact: (name) ->
    @facts.findByName(name).value

  url: ->
    "/api/nodes/#{@name}"

