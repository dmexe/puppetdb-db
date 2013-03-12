event     = null
timestamp = null
attrs     = null

describe 'Event', ->
  beforeEach ->
    timestamp = new Date
    attrs =
      "timestamp": timestamp.toString()
      "resource-type": "File"
      "resource-title": '/etc'
    event = new App.Event(attrs)

  it 'should has timestamp', ->
    tm = Date.parse(timestamp.toString())
    expect(event.timestamp).toEqual tm

  it "should has timeAt", ->
    tm = timestamp.toLocaleTimeString()
    expect(event.timeAt).toEqual tm

  it "should has resource", ->
    expect(event.resource).toEqual "File[/etc]"
