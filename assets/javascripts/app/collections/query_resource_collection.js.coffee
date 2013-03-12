window.App.QueryResourceCollection = Backbone.Collection.extend
  model: App.QueryResource

  initialize: (models, options) ->
    @query = options.query

  url: ->
    "/api/query?resource=#{@query}"

