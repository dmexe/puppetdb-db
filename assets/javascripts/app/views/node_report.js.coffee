window.App.NodeReportView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->

  activate: (node, events) ->
    @node   = node
    @events = events
    @events.fetch().then @render.bind(@)

  render: ->
    @html 'events/index', events: @events
