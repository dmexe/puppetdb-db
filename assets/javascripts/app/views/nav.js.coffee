window.App.NavView = Backbone.View.extend
  el: '.header'

  initialize: ->
    @defaultValues = [{ link: "/", name: "PuppetDB Dashboard" }]

  render:(active, values) ->
    @html 'layout/navigation', values: values, active: active

  activateDashboard: ->
    @render '/', @defaultValues

  activateNode: (node) ->
    values = @nodeValues node
    @render node.link, values

  activateNodeReports: (node) ->
    values = @nodeValues node
    @render node.reports.link, values

  activateNodeReport: (node, hash) ->
    values = @nodeValues node
    values.push link: hash, name: hash.substring(0,6)
    @render hash, values

  nodeValues:(node) ->
    values = _.clone(@defaultValues)
    values.push node
    values.push link: node.reports.link, name: 'Reports'
    values
