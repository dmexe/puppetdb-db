window.App.Report = Backbone.Model.extend
  initialize: ->
    @hash    = @get "hash"
    @version = @get "configuration-version"
    @link    = "#{@collection.link}/#{@hash}"
    @name    = @hash.substring(0,6)
    @events  = new App.EventsCollection([], report: @)

  startAtTimestamp: ->
    Date.parse(@get "start-time")

  endAtTimestamp: ->
    Date.parse(@get "end-time")

  startAt: ->
    new Date(@startAtTimestamp()).toLocaleString()

  duration: ->
    (@endAtTimestamp() - @startAtTimestamp()) / 1000

  summary: ->
    @get "_stats"
