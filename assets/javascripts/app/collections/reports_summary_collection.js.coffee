window.App.ReportsSummaryCollection = Backbone.Collection.extend
  model: App.ReportSummary

  initialize: (models, options) ->
    @node = options.node

  url: ->
    "/api/nodes/#{@node.name}/reports/summary"

  comparator: (summary) ->
    summary.time

  findByHash: (hash) ->
    @where(hash: hash)[0]

  forChart: ->
    end   = moment().endOf("day")
    begin = moment(end).subtract("day", 30).startOf("day")

    rs = { "days": [], "success": [], "failed": [], "duration": [] }

    while(begin.valueOf() < end.valueOf())

      nextDay = moment(begin).add("day", 1).startOf("day")

      daily = @filter (it) ->
        it.tm >= begin.valueOf() && it.tm < nextDay.valueOf()

      fun = (a,i) -> a + i
      success = _.map(daily, (i) -> i.success || 0)
      success = _.reduce(success, fun, 0)
      failed = _.map(daily, (i) -> i.failed || 0)
      failed = _.reduce(failed, fun, 0)
      duration = _.map(daily, (i) -> i.duration || 0)
      if _.isEmpty(duration)
        duration = 0.0
      else
        duration = _.reduce(duration, fun, 0) / daily.length

      rs["days"].push     begin.format("D MMM")
      rs["success"].push  success
      rs["failed"].push   failed
      rs["duration"].push duration

      begin = nextDay
    rs

