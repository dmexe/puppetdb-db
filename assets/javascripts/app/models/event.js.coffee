window.App.Event = Backbone.Model.extend
  initialize: ->
    @timestamp = Date.parse(@get "timestamp")
    @timeAt    = new Date(@timestamp).toLocaleTimeString()
    @message   = @get "message"
    @newVal    = @get "new-value"
    @resource  = "#{@get "resource-type"}[#{@get "resource-title"}]"
    @status    = @get "status"


