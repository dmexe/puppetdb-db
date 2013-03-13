class App.SummaryChart
  constructor: (data, target) ->
    series = [
      { name: "success",  data: data.success, type: "areaspline", yAxis: 0, color: "#4688cc" }
      { name: "failed",   data: data.failure, type: "areaspline", yAxis: 0, color: "Maroon" }
    ]

    yAxis = [
      { title: { text: "resources" }}
    ]

    if data.requests
      requests = { name: "num requests", data: data.requests, type: "spline", yAxis: 1, color: "Gainsboro", lineWidth: 1, marker: { enabled: false} }
      series.push requests
      yAxis.push { title: {text: "num requests"}, opposite: true }

    chart = new Highcharts.Chart
      chart:
        renderTo: target
        animation: false

      title:
        text: 'Reports in last 30 days'

      xAxis:
        categories:
          data.days

      yAxis: yAxis
      series: series

      plotOptions:
        line:
          animation: false
        series:
          animation: false

      legend:
        align: 'right'
        verticalAlign: 'top'
        y: -4
        floating: true
        borderWidth: 0

