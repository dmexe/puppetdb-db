window.App.Node = Backbone.Model.extend
  initialize: ->
    @name           = @get("name")
    @link           = "/nodes/#{@name}"
    @facts          = new App.FactsCollection([], node: @)
    @reports        = new App.ReportsCollection([], node: @)

  reportAtTimestamp: ->
    Date.parse(@get "report_timestamp")

  reportAt: ->
    new Date(@reportAtTimestamp()).toLocaleString()

  fact: (name) ->
    @facts.findByName(name).value

