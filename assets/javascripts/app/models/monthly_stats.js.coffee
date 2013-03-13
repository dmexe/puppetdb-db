window.App.MonthlyStats = Backbone.Model.extend
  initialize: ->

  url: ->
    '/api/stats/monthly'

  forChart: ->
    rs = { "days": [], "success": [], "failure": [], "requests": [] }

    _.each @attributes, (day) ->
      tm = moment(day[0]).format("D MMM")
      rs.days.push tm
      it = day[1]
      rs.success.push  it.success
      rs.failure.push  it.failure
      rs.requests.push it.requests
    rs

window.App.NodeMonthlyStats = Backbone.Model.extend
  initialize:(_unused, options) ->
    @node = options.node

  url: ->
    "/api/nodes/#{@node.name}/stats/monthly"

  forChart: ->
    rs = { "days": [], "success": [], "failure": [], "requests": [] }

    _.each @attributes, (day) ->
      tm = moment(day[0]).format("D MMM")
      rs.days.push tm
      it = day[1]
      rs.success.push  it.success
      rs.failure.push  it.failure
      rs.requests.push it.requests
    rs
