attrs = null
metrics = null

describe 'Metrics', ->
  beforeEach ->
    attrs =
      "avg_resources_per_node": "10"
    metrics = new App.Metrics attrs

  it "should has avgResourcesPerNode()", ->
    expect(metrics.avgResourcesPerNode()).toEqual 10
