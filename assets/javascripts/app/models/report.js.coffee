window.App.Report = Backbone.Model.extend
  initialize: ->
    @hash    = @get "hash"
    @version = @get "configuration-version"
    @link    = "#{@collection.link}/#{@hash}"
    @name    = @hash.substring(0,6)
    @events  = new App.EventsCollection([], report: @)

  startAt: ->
    moment(@get "start-time")

  endAt: ->
    moment(@get "end-time")

  duration: ->
    @endAt().seconds() - @startAt().seconds()

  summary: ->
    @get "_stats"
