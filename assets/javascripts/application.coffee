#= require vendor/jquery-1.9.1.js
#= require vendor/bootstrap
#= require vendor/underscore
#= require vendor/backbone
#= require vendor/highcharts
#= require vendor/moment
#= require_self
#= require      app/router
#= require_tree ./app/lib
#= require_tree ./app/views
#= require_tree ./app/templates
#= require_tree ./app/models
#= require_tree ./app/collections

window.App ||= {}

App.Helpers =
  linkTo: (objectOrTitle, url) ->
    unless url
      url = objectOrTitle.link
      objectOrTitle = objectOrTitle.name
    else
    @safe "<a href=\"#{url}\">#{objectOrTitle}</a>"

  truncate: (text, length = 30, tail = "...") ->
    return "" unless text
    if text.length < length
      text
    else
      text.substring(0,length) + tail

  eventStatusLabel: (status) ->
    h = "skipped": "", "success": "label-success", "failure": "label-important"
    l = h[status]
    label = "<span class=\"label #{l}\">" + escape(status) + "</span>"
    @safe(label)

  reportSummary: (summary) ->
    h = "skipped": "", "success": "badge-success"
    h = []
    h.push "<span class=\"label label-success\">#{summary.success}</span>" if summary.success
    h.push "<span class=\"label label-important\">#{summary.failure}</span>" if summary.failure
    h.push "<span class=\"label\">#{summary.skipped}</span>" if summary.skipped
    @safe h.join("&nbsp;")

Backbone.View.prototype.jst = (name, context) ->
  context ||= {}
  content = $.extend context, App.Helpers
  window.JST["app/templates/" + name](context)

Backbone.View.prototype.html = (template, context) ->
  @$el.html @jst(template, context)
