window.App.NavView = Backbone.View.extend
  el: '.header'

  render:(options = {}) ->
    @html 'layout/navigation', values: @values(options)

  values: (options) ->
    @defaultValues ||= [{ link: "/", name: "PuppetDB Dashboard" }]
    val = _.clone(@defaultValues)
    if _.isEmpty(options)
      val.active = "/"
    else if options.node
      val.push options.node
      val.push options.node.reports
      if options.reports
        val.active = options.node.reports.link
      else
        val.active = options.node.link
    val
