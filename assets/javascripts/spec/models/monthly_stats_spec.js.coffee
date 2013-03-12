timestamp    = null
attrs        = null
monthlyStats = null

describe 'MonthlyStats', ->

  beforeEach ->
    timestamp = moment("Dec 25, 1995").toDate().getTime()
    attrs =
      [[timestamp, {success: 1, failed: 2, requests:3}]]
    monthlyStats = new App.MonthlyStats attrs

  describe ".forChart()", ->
    it "should build hash for chart", ->
      expect(monthlyStats.forChart().days).toEqual     ['25 Dec']
      expect(monthlyStats.forChart().success).toEqual  [1]
      expect(monthlyStats.forChart().failed).toEqual   [2]
      expect(monthlyStats.forChart().requests).toEqual [3]

