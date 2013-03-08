#= require vendor/jquery-1.9.1.js
#= require vendor/bootstrap
#= require vendor/underscore
#= require vendor/backbone
#= require_self
#= require      app/router
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

Backbone.View.prototype.jst = (name, context) ->
  context ||= {}
  content = $.extend context, App.Helpers
  window.JST["app/templates/" + name](context)

Backbone.View.prototype.html = (template, context) ->
  @$el.html @jst(template, context)
