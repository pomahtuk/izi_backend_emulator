"use strict"

# Declare app level module which depends on filters, and services
angular.module("myApp", ["myApp.filters", "myApp.services", "myApp.directives", "ui.bootstrap", "ui.select2"]).config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $routeProvider.when("/", ########################################### Root part
    templateUrl: "partials/index"
    controller: CommonIndexCtrl
  ).when("/firm/add/", ############################################### Firm part
    templateUrl: "partials/editFirm"
    controller: AddFirmCtrl
  ).when("/firm/view/:id",
    templateUrl: "partials/viewFirm"
    controller: ViewFirmCtrl
  ).when("/firm/edit/:id",
    templateUrl: "partials/editFirm"
    controller: EditFirmCtrl
  ).when("/firm/delete/:id",
    templateUrl: "partials/deleteFirm"
    controller: DeleteFirmCtrl
  ).when("/firm/",
    templateUrl: "partials/indexFirm"
    controller: FirmIndexCtrl
  ).when("/curier/add/", ############################################# Curier part
    templateUrl: "partials/editCurier"
    controller: AddCurierCtrl
  ).when("/curier/view/:id",
    templateUrl: "partials/viewCurier"
    controller: ViewCurierCtrl
  ).when("/curier/edit/:id",
    templateUrl: "partials/editCurier"
    controller: EditCurierCtrl
  ).when("/curier/delete/:id",
    templateUrl: "partials/deleteCurier"
    controller: DeleteCurierCtrl
  ).when("/curier/",
    templateUrl: "partials/indexCurier"
    controller: CurierIndexCtrl
  ).when("/order/add/", ############################################# Order part
    templateUrl: "partials/editOrder"
    controller: AddOrderCtrl
  ).when("/order/view/:id",
    templateUrl: "partials/viewOrder"
    controller: ViewOrderCtrl
  ).when("/order/edit/:id",
    templateUrl: "partials/editOrder"
    controller: EditOrderCtrl
  ).when("/order/delete/:id",
    templateUrl: "partials/deleteOrder"
    controller: DeleteOrderCtrl
  ).when("/order/",
    templateUrl: "partials/indexOrder"
    controller: OrderIndexCtrl
  ).when("/reports/day/", ############################################# Report part
    templateUrl: "partials/reportDayTotal"
    controller: ReportDayTotal
  ).when("/reports/month/",
    templateUrl: "partials/reportDayTotal"
    controller: ReportMonthCtrl
  ).when("/reports/common/",
    templateUrl: "partials/reportCommon"
    controller: ReportCommonCtrl
  ).when("/reports/constructor/",
    templateUrl: "partials/reportConstructor"
    controller: ReportConstructorCtrl
  ).otherwise redirectTo: "/"
  $locationProvider.html5Mode true
]