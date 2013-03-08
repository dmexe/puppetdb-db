window.App.Fact = Backbone.Model.extend
  initialize: ->
    @name = @get("name")
    @value = @get("value")
