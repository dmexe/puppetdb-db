window.App.EventsCollection = Backbone.Collection.extend
  model: App.Event

  initialize: (models, options) ->
    @report = options.report
    @link   = @report.link
    @name   = @report.name

  url: ->
    @report.collection.url() + "/#{@report.hash}"

  comparator: (event) ->
    event.timestamp * -1

  summary: ->
    return {} if _.isEmpty(@models)

    fun = (ac, it) ->
      ac[it.status] ||= 0
      ac[it.status] += 1
      ac

    _.reduce(@models, fun, {})


