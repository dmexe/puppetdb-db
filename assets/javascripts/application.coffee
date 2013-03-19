#= require_self
#= require        app/router
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

  linkToNode: (nodeName) ->
    @linkTo nodeName, "/nodes/#{nodeName}"

  linkToNodeReport: (report, options) ->
    title = options.title || report.hash
    @linkTo title, "/nodes/#{report.nodeName}/reports/#{report.hash}"

  truncate: (text, length = 30, tail = "...") ->
    return "" unless text
    if text.length < length
      text
    else
      cut = text.toString().substring(0,length) + tail
      @safe "<span class=\"truncated-text\" title=\"#{@h text.toString()}\">#{@h cut}</span>"

  eventStatusLabel: (status) ->
    h = "skipped": "", "success": "label-info", "failure": "label-important"
    l = h[status]
    label = "<span class=\"label #{l}\">" + @h(status) + "</span>"
    @safe(label)

  reportStats: (summary) ->
    h = []
    h.push "<span class=\"label label-info\">#{@h summary.success}</span>" if summary.success
    h.push "<span class=\"label label-important\">#{@h summary.failure}</span>" if summary.failure
    h.push "<span class=\"label\">#{@h summary.skipped}</span>" if summary.skipped
    @safe h.join("&nbsp;")

  h: (text) ->
    text.toString().replace /\W/g, (chr) ->
      '&#' + chr.charCodeAt(0) + ';'

App.BackboneViewJST =
  jst: (name, context) ->
    context ||= {}
    content = $.extend context, App.Helpers
    window.JST["app/templates/" + name](context)

  html: (template, context) ->
    @$el.html @jst(template, context)
    @$el

App.BackboneCollectionFetchOnce =
  fetchOnce: (options) ->
    if @length == 0
      fetch(options)
    else
      dfd = $.Deferred()
      dfd.resolve().promise()

_.extend(Backbone.View.prototype, App.BackboneViewJST)
_.extend(Backbone.Collection.prototype, App.BackboneCollectionFetchOnce)


$(document).ready ->
  unless window.jasmine
    window.appRouter = new App.Router
    Backbone.history.start(pushState: true, root: "/ui/")

    $("body").on "click", "a", (ev) ->
      ev.preventDefault()
      el = $(ev.currentTarget)
      href = el.attr("href")
      unless href.match(/^#/)
        window.appRouter.navigate(el.attr("href"), trigger: true)
      true
