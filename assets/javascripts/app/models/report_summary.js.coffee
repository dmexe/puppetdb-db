window.App.ReportSummary = Backbone.Model.extend
  initialize: ->
    @hash     = @get "hash"
    @duration = @get "duration"
    @skipped  = @get "skipped"
    @success  = @get "success"
    @failure  = @get "failure"
    @tm       = @get "timestamp"
    @time     = new Date(@get "timestamp")

