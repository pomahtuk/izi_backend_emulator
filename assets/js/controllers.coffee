"use strict"

# Controllers 
@SidebarCtrl = ($scope, $http, $filter, sharedProperties) ->
  #$scope.page = 'index'
  $scope.page = sharedProperties.getProperty()

  $scope.$on 'pageChange', ->
    $scope.page = sharedProperties.getProperty()

  true


#
# Root controller
#
@CommonIndexCtrl = ($scope, $http, $filter, sharedProperties) ->

  sharedProperties.setProperty('index')

  $scope.weekdays    = ['','Воскресенье','Понедельник','Вторник','Среда','Четверг','Пятница','Суббота']

  $scope.chart_data  = []

  $scope.chart_data[0]  = [
    ['2008', 0]
  ]

  $scope.chart_data[1]  = [
    ['2008', 0]
  ]


  $scope.range = 'week'

  $scope.week_income    = 0 
  $scope.month_income   = 0
  $scope.week_delivery  = 0
  $scope.month_delivery = 0

  $http.get("/data/order/?limit=10").success (data, status, headers, config) ->
    $scope.orders      = data.orders
    $scope.maxSize     = 10
    $scope.noOfPages   = Math.ceil(data.total / $scope.maxSize)
    $scope.currentPage = 1

  $http.get("/data/chart/order/").success (data, status, headers, config) ->
    delivery = []
    total    = []
    $scope.week_income    = 0
    $scope.week_delivery  = 0
    for item in data
      delivery_item = []
      total_item = []
      $scope.week_income += item.total
      $scope.week_delivery += item.count
      date = new Date item.date
      #new_item[0] = Date.parse(item.date)
      delivery_item[0] = "#{date.getDate()}.#{date.getMonth() + 1}.#{date.getFullYear()}, #{$scope.weekdays[item._id]}"
      total_item[0]    = "#{date.getDate()}.#{date.getMonth() + 1}.#{date.getFullYear()}, #{$scope.weekdays[item._id]}"
      delivery_item[1] = item.count
      total_item[1]    = item.total
      delivery.push delivery_item
      total.push total_item 
    $scope.chart_data[0] = delivery
    $scope.chart_data[1] = total

  $http.get("/data/chart/order/month").success (data, status, headers, config) ->
    tmp = []
    $scope.month_income    = 0
    $scope.month_delivery  = 0
    for item in data
      $scope.month_income   += item.total
      $scope.month_delivery += item.count

  $scope.change_range = () ->
    #console.log $scope.range
    $http.get("/data/chart/order/#{$scope.range}").success (data, status, headers, config) ->
      tmp = []
      for item in data
        new_item = []
        date = new Date item.date
        item.weekday = "#{date.getDate()}.#{date.getMonth() + 1}.#{date.getFullYear()}, #{$scope.weekdays[item._id]}"
        new_item[0] = item.weekday
        new_item[1] = item.count
        tmp.push new_item

      $scope.chart_data = tmp

# Firm controllers
#
@FirmIndexCtrl = ($scope, $http, $filter, sharedProperties) ->
  sharedProperties.setProperty('firm')
  $http.get("/data/firm/").success (data, status, headers, config) ->
    $scope.firms = data
    $scope.noOfPages = Math.ceil($scope.firms.length / 10)
    $scope.currentPage = 1
    $scope.maxSize = 10
    $scope.search  = ''

@AddFirmCtrl = ($scope, $http, $location, sharedProperties) ->
  sharedProperties.setProperty('firm')
  $scope.firm = {}
  $scope.firm.edit = false
  $scope.editFirm = ->
    $http.post("/data/firm/", $scope.firm).success (data) ->
      $location.path "/firm"

@ViewFirmCtrl = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('firm')
  $http.get("/data/firm/" + $routeParams.id).success (data) ->
    $scope.firm   = data[0]
  $http.get("/data/order/firm/" + $routeParams.id).success (data, status, headers, config) ->
    $scope.orders = data

@EditFirmCtrl = ($scope, $http, $location, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('firm')
  $http.get("/data/firm/" + $routeParams.id).success (data) ->
    $scope.firm = data[0]
    $scope.firm.edit = true

  $scope.editFirm = ->
    $http.post("/data/firm/" + $routeParams.id, $scope.firm).success (data) ->
      $location.url "/view/firm/" + $routeParams.id

@DeleteFirmCtrl = ($scope, $http, $location, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('firm')
  $http.get('/data/firm/' + $routeParams.id).success (data) ->
      $scope.firm = data[0]

  $scope.deleteFirm = ->
    $http.delete('/data/firm/' + $routeParams.id).success (data) ->
        $location.url('/firm')

  $scope.home = ->
    $location.url('/firm')


#
# Curier controllers
#
@CurierIndexCtrl = ($scope, $http, $filter, sharedProperties) ->
  sharedProperties.setProperty('curier')
  $http.get("/data/curier/").success (data, status, headers, config) ->
    $scope.curiers = data
    $scope.noOfPages = Math.ceil($scope.curiers.length / 10)
    $scope.currentPage = 1
    $scope.maxSize = 10
    $scope.processed = $filter("filter")($scope.curiers, $scope.search).length

@AddCurierCtrl = ($scope, $http, $location, sharedProperties) ->
  sharedProperties.setProperty('curier')
  $scope.curier = {}
  $scope.curier.edit = false
  $scope.editCurier = ->
    $http.post("/data/curier/", $scope.curier).success (data) ->
      $location.path "/curier"

@ViewCurierCtrl = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('curier')
  $http.get("/data/curier/" + $routeParams.id).success (data) ->
    $scope.curier = data[0]
  $http.get("/data/order/curier/" + $routeParams.id).success (data, status, headers, config) ->
    $scope.orders = data

@EditCurierCtrl = ($scope, $http, $location, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('curier')
  $http.get("/data/curier/" + $routeParams.id).success (data) ->
    $scope.curier = data[0]
    $scope.curier.edit = true

  $scope.editCurier = ->
    $http.post("/data/curier/" + $routeParams.id, $scope.curier).success (data) ->
      $location.url "/view/curier/" + $routeParams.id

@DeleteCurierCtrl = ($scope, $http, $location, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('curier')
  $http.get('/data/curier/' + $routeParams.id).success (data) ->
      $scope.curier = data[0]

  $scope.deleteCurier = ->
    $http.delete('/data/curier/' + $routeParams.id).success (data) ->
        $location.url('/')

  $scope.home = ->
    $location.url('/curier')


#
# Order controllers
#
@OrderIndexCtrl = ($scope, $http, $filter, sharedProperties) ->
  sharedProperties.setProperty('order')
  $http.get("/data/order/?limit=10").success (data, status, headers, config) ->
    $scope.orders         = data.orders
    $scope.maxSize        = 10
    $scope.noOfPages      = Math.ceil(data.total / $scope.maxSize)
    $scope.currentPage    = 1
    $scope.page_change = (page) ->
      order = 1
      order = -1 if $scope.reverse
      page_from = (page - 1) * $scope.maxSize
      $http.get("/data/order/?limit=10&from=#{page_from}&field=#{$scope.predicate}&order=#{order}").success (data, status, headers, config) ->
        $scope.orders = data.orders

    $scope.sort_server = () ->
      console.log $scope.predicate, $scope.reverse
      order = 1
      order = -1 if $scope.reverse
      $http.get("/data/order/?limit=10&field=#{$scope.predicate}&order=#{order}&from=#{($scope.currentPage - 1) * 10}").success (data, status, headers, config) ->
        $scope.orders = data.orders

@AddOrderCtrl = ($scope, $http, $location, sharedProperties) ->
  sharedProperties.setProperty('order')
  $scope.order = {}
  $scope.curiers = []
  $scope.firms   = []
  $scope.order.edit = false
  $scope.order.date = new Date

  $http.get("/data/curier/").success (data) ->
    $scope.curiers = data

  $http.get("/data/firm/").success (data) ->
    $scope.firms = data

  $scope.editOrder = ->
    $scope.order.day_of_week = $scope.order.date.getDay()
    $http.post("/data/order/", $scope.order).success (data) ->
      $location.path "/order"

@ViewOrderCtrl = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('order')
  $http.get("/data/order/" + $routeParams.id).success (data) ->
    $scope.order = data[0]

@EditOrderCtrl = ($scope, $http, $location, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('order')
  $scope.order   = {}
  $scope.curiers = []
  $scope.firms   = []

  $scope.select2Options = {
      'multiple': false
      'placeholder': "Выбирите..."
  }

  $http.get("/data/order/" + $routeParams.id).success (data) ->
    $scope.order = data[0]
    $scope.order.edit   = true
    $scope.order.date   = new Date $scope.order.date
    $scope.order.firm   = $scope.order.firm._id
    $scope.order.curier = $scope.order.curier._id

  $http.get("/data/curier/").success (data) ->
    $scope.curiers = data

  $http.get("/data/firm/").success (data) ->
    $scope.firms = data

  $scope.editOrder = ->
    $scope.order.day_of_week = $scope.order.date.getDay()
    $http.post("/data/order/" + $routeParams.id, $scope.order).success (data) ->
      $location.url "/view/order/" + $routeParams.id

@DeleteOrderCtrl = ($scope, $http, $location, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('order')
  console.log $routeParams.id
  $http.get('/data/order/' + $routeParams.id).success (data) ->
    $scope.order = data[0]

  $scope.deleteOrder = ->
    $http.delete('/data/order/' + $routeParams.id).success (data) ->
        $location.url('/order')

  $scope.home = ->
    $location.url('/order')

#
# Reports controllers
#
@ReportDayTotal = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('reports')
  $scope.day = true
  $scope.date = new Date()

  $scope.dateChange = () ->
    $http.get("/data/report/order/day/total/#{$scope.date.toISOString()}").success (data) ->
      $scope.day_orders = data

  $http.get("/data/report/order/day/total/").success (data) ->
    $scope.day_orders = data

@ReportConstructorCtrl = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('reports')
  $http.get("/data/order/").success (data) ->
    $scope.order = data[0]

@ReportMonthCtrl = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('reports')
  $scope.day = false
  $scope.date = new Date()

  $scope.dateChange = () ->
    $http.get("/data/report/order/month/total/#{$scope.date.toISOString()}").success (data) ->
      $scope.day_orders = data

  $http.get("/data/report/order/month/total/").success (data) ->
    $scope.day_orders = data

@ReportCommonCtrl = ($scope, $http, $routeParams, sharedProperties) ->
  sharedProperties.setProperty('reports')
  $scope.date = new Date()

  $scope.dateChange = () ->
    $http.get("/data/report/order/day/all/#{$scope.date.toISOString()}").success (data) ->
      $scope.orders = data

  $http.get("/data/report/order/day/all/").success (data) ->
    $scope.orders = data