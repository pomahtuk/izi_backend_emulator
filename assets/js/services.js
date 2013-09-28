'use strict';

/* Services */


// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('myApp.services', []).
  value('version', '0.1');

angular.module('myApp.services', [])
    .service('sharedProperties', function ($rootScope) {
        var property = 'index';

        return {
            getProperty: function () {
                return property;
            },
            setProperty: function(value) {
                property = value;
                $rootScope.$broadcast('pageChange');
            }
        };
    });