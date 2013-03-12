name      = null
timestamp = null
node      = null

describe 'Node', ->
  beforeEach ->
    timestamp = new Date
    name = 'example.com'
    attrs =
      name: name
      report_timestamp: timestamp.toString()
    node = new App.Node attrs

   it "should has link", ->
     expect(node.link).toEqual "/nodes/example.com"

   it "should has reportAtTimestamp()", ->
     tm = Date.parse(timestamp.toString())
     expect(node.reportAtTimestamp()).toEqual tm

   it "should has reportAt()", ->
     expect(node.reportAt()).toEqual timestamp.toLocaleString()

   xit "should has fact()"
