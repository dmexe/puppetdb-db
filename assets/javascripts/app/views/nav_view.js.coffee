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
      if options.report
        val.push options.report

      val.active = options.report.link if options.report
      val.active = options.node.reports.link if options.reports
      val.active ||= options.node.link
    val
