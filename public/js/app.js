(function() {
  "use strict";
  this.app = angular.module("Museum", ["Museum.filters", "Museum.services", "Museum.directives", "Museum.controllers", "ui.bootstrap", "ui.bootstrap.tpls", "angularLocalStorage", "ngProgress", "jm.i18next"]);

  app.config(function($locationProvider, $routeProvider) {
    $routeProvider.when("/", {
      templateUrl: "partials/prototype.html",
      controller: "IndexController",
      resolve: {
        data: function($q, $route, backendWrapper) {
          var deferred;
          deferred = $q.defer();
          backendWrapper.fetch_data(null, deferred);
          return deferred.promise;
        }
      }
    }).when("/:museum_id", {
      templateUrl: "partials/prototype.html",
      controller: "IndexController",
      resolve: {
        data: function($q, $route, backendWrapper) {
          var deferred, museum_id;
          deferred = $q.defer();
          museum_id = $route.current.params.museum_id;
          backendWrapper.fetch_data(museum_id, deferred);
          return deferred.promise;
        }
      }
    });
    $locationProvider.html5Mode(true);
    return $locationProvider.hashPrefix('!');
  });

  angular.module("jm.i18next").config(function($i18nextProvider) {
    return $i18nextProvider.options = {
      useCookie: true,
      useLocalStorage: false,
      resGetPath: "../locales/__lng__/__ns__.json"
    };
  });

}).call(this);
