window.App.MonthlyStats = Backbone.Model.extend
  initialize: ->

  url: ->
    '/api/stats/monthly'

  forChart: ->
    rs = { "days": [], "success": [], "failed": [], "requests": [] }

    _.each @attributes, (day) ->
      tm = moment(day[0]).format("D MMM")
      rs.days.push tm
      it = day[1]
      rs.success.push  it.success
      rs.failed.push   it.failed
      rs.requests.push it.requests
    rs

window.App.NodeMonthlyStats = Backbone.Model.extend
  initialize:(_unused, options) ->
    @node = options.node

  url: ->
    "/api/nodes/#{@node.name}/stats/monthly"

  forChart: ->
    rs = { "days": [], "success": [], "failed": [], "duration": [] }

    _.each @attributes, (day) ->
      tm = moment(day[0]).format("D MMM")
      rs.days.push tm
      it = day[1]
      rs.success.push  it.success
      rs.failed.push   it.failed
      if it.requests == 0
        rs.duration.push 0
      else
        rs.duration.push(it.duration / it.requests)
    rs
