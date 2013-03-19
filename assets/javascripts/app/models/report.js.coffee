window.App.Report = Backbone.Model.extend
  initialize: ->
    @hash     = @get "hash"
    @version  = @get "configuration-version"
    @nodeName = @get "certname"

  startAt: ->
    moment(@get "start-time")

  endAt: ->
    moment(@get "end-time")

  duration: ->
    @endAt().seconds() - @startAt().seconds()

  stats: ->
    @get "_stats"
