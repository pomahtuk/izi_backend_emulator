# Directives 
angular.module("myApp.directives", [])

# For Morris JS Charts
#angular.module("myApp.directives", [])
.directive 'ngchart', ->
  require: "?ngModel"
  link: (scope, elem, attrs) ->

    data = scope[attrs.ngModel]
    # create the chart

    chart = new Highcharts.Chart
      chart:
        alignTicks: false
        renderTo: attrs.id

      rangeSelector:
        selected: 0

      series: [
        {
          type: "column"
          name: attrs.chartLabels.split(',')[0]
          data: data[0]
        },
        {
          type: "column"
          name: attrs.chartLabels.split(',')[1]
          data: data[1]
        }
      ]

    scope.$watch attrs.ngModel, (newValue, oldValue) ->
      if newValue
        for value, index in newValue
          chart.series[index].setData value


    , true

    elem.show()

    true
    # chart = null

    # scope.$watch attrs.ngModel, (newValue, oldValue) ->
    #   if newValue
    #     elem.empty()
    #     data = scope[attrs.ngModel]

    #     options = {
    #       element: attrs.id
    #       data: data
    #       xkey: attrs.chartXkey
    #       ykeys: attrs.chartYkeys.split(',')
    #       labels: attrs.chartLabels.split(',')
    #     }

    #     chart = new Morris.Bar options
    # , true

    # elem.show()

# For datepicker
#angular.module("myApp.directives", [])
.directive 'jqdatepicker', ->
  require: "?ngModel"
  link: (scope, elem, attrs) ->
    data = scope[attrs.ngModel]
    elem.val "#{data.getDay()}/#{data.getMonth()}/#{data.getFullYear()}"
    elem.DatePicker
      format: "d/m/Y"
      date: data
      current: data
      starts: 1
      position: "bottom"
      onBeforeShow: ->
        elem.DatePickerSetDate data, true

      onChange: (formated, dates) ->
        scope.date = dates
        scope.$apply()
        scope[attrs.jqCallback]()
        elem.val formated
        elem.DatePickerHide()

    scope.$watch attrs.ngModel, (newValue, oldValue) ->
      if newValue
        elem.DatePickerSetDate newValue
        elem.val elem.DatePickerGetDate(true)
    , true

    elem.show()

    true