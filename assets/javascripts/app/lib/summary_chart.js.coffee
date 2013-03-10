class App.SummaryChart
  constructor: (data, target) ->
    series = [
      { name: "success",  data: data.success, type: "column", yAxis: 0, color: "SeaGreen" }
      { name: "failed",   data: data.failed, type: "column", yAxis: 0, color: "Maroon" }
    ]

    yAxis = [
      { title: { text: "resources" }}
    ]

    if data.duration
      duration = { name: "duration", data: data.duration, type: "spline", yAxis: 1, color: "SteelBlue", lineWidth: 1, marker: { enabled: false} }
      series.push duration
      yAxis.push { title: {text: "duration sec."}, opposite: true }

    if data.requests
      requests = { name: "requests", data: data.requests, type: "spline", yAxis: 1, color: "Gainsboro", lineWidth: 1, marker: { enabled: false} }
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
        column:
          stacking: 'normal'
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

