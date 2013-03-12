window.App.SearchView = Backbone.View.extend
  el: '.js-view-container'

  initialize: ->
    $("body").on "submit", ".navigation .search form", @navigate.bind(@)

  navigate: ->
    window.appRouter.navigate("/query/#{@query().val()}", trigger: true)
    false

  activate: (q) ->
    @collection = new App.QueryResourceCollection [], query: q
    @collection.on "sync", @render, @
    @collection.fetch()
    @query().val(q)

  render: ->
    @html 'search/resources', collection: @collection

  query: ->
    $(".navigation .search input")
