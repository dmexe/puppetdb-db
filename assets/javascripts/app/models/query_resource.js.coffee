window.App.QueryResource = Backbone.Model.extend
  initialize: ->
    @node = @get "certname"
    @parameters = @get "parameters"
    @type = @get 'type'
    @title = @get 'title'
    @name = "#{@type}[#{@title}]"
