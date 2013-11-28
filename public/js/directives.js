(function() {
  "use strict";
  angular.module("Museum.directives", []).directive("ngBlur", function() {
    return function(scope, elem, attrs) {
      return elem.bind("blur", function() {
        return scope.$apply(attrs.ngBlur);
      });
    };
  }).directive("ngFocus", function($timeout) {
    return function(scope, elem, attrs) {
      return scope.$watch(attrs.ngFocus, function(newval) {
        if (newval) {
          return $timeout((function() {
            return elem[0].focus();
          }), 0, false);
        }
      });
    };
  }).directive("focusMe", function($timeout, $parse) {
    return {
      link: function(scope, element, attrs) {
        var model;
        model = $parse(attrs.focusMe);
        scope.$watch(model, function(value) {
          if (value === true) {
            return $timeout(function() {
              return element[0].focus();
            });
          }
        });
        return element.bind("blur", function() {
          return scope.$apply(model.assign(scope, false));
        });
      }
    };
  }).directive("stopEvent", function() {
    return {
      link: function(scope, element, attr) {
        return element.bind(attr.stopEvent, function(e) {
          return e.stopPropagation();
        });
      }
    };
  }).directive("resizer", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        elem.focus(function() {
          return elem.animate({
            'width': '+=150'
          }, 200);
        });
        return elem.blur(function() {
          return elem.animate({
            'width': '-=150'
          }, 200);
        });
      }
    };
  }).directive("toggleMenu", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        return elem.click(function() {
          $('.museum_navigation_menu').slideToggle(300);
          return setTimeout(function() {
            return $.scrollTo(0, 0);
          }, 0);
        });
      }
    };
  }).directive("toggleFilters", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        return elem.click(function() {
          var filters, margin, placeholder;
          filters = $('.filters_bar');
          placeholder = $('.filters_placeholder');
          margin = filters.css('top');
          if (margin === '0px') {
            filters.animate({
              'top': '-44px'
            }, 300);
            placeholder.animate({
              'height': '0px'
            }, 300);
          } else {
            filters.animate({
              'top': '0px'
            }, 300);
            placeholder.animate({
              'height': '44px'
            }, 300);
          }
          return scope.filters_opened = !scope.filters_opened;
        });
      }
    };
  }).directive('postRender', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var opener;
        if (scope.$last) {
          $timeout(scope.grid, 200);
          opener = {
            target: $('.museum_edit_opener')
          };
          $("ul.exhibits.common").scrollspy({
            min: 50,
            max: 99999,
            onEnter: function(element, position) {
              $(".float_menu").addClass("navbar-fixed-top");
              $(".navigation").addClass("bottom-padding");
              return $(".to_top").show();
            },
            onLeave: function(element, position) {
              $(".float_menu").removeClass("navbar-fixed-top");
              $(".navigation").removeClass("bottom-padding");
              if (!$(".to_top").hasClass('has_position')) {
                return $(".to_top").hide();
              }
            },
            onTick: function(position, state, enters, leaves) {
              if (scope.museum_edit_dropdown_opened) {
                return scope.show_museum_edit(opener);
              }
            }
          });
        }
        return true;
      }
    };
  }).directive("switchpubitem", function($timeout, storySetValidation, $i18next) {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        provider: '=ngProvider',
        current_museum: '=ngMuseum',
        trans: '=translations',
        field: '@field',
        field_type: '@type',
        root: '=root'
      },
      template: "<div class=\"btn-group pull-right item_publish_settings\" ng-hide=\"item.status == 'draft'\">\n  <button class=\"btn btn-default dropdown-toggle\" ng-class=\"{'btn-success': item.status == 'published', 'btn-warning': item.status == 'passcode', 'btn-danger': item.status == 'opas_invisible'}\" ng-switch on=\"item[field]\">\n    <div class=\"extra\" ng-switch ng-switch on=\"item[field]\">\n      <i ng-switch-when=\"published\" class=\"icon-globe\"></i>\n      <i ng-switch-when=\"passcode\" class=\"icon-lock\"></i>\n      <i ng-switch-when=\"opas_invisible\" class=\"icon-eye-close\"></i>\n    </div>\n    <!-- span ng-switch-default>{{ 'Publish' | i18next }}</span> -->\n    <span ng-switch-when=\"published\">{{ 'Published' | i18next }}</span>\n    <span ng-switch-when=\"passcode\">{{ 'Private' | i18next }}</span>\n    <span ng-switch-when=\"opas_invisible\">{{ 'Invisible' | i18next }}</span>\n    <span>\n      &nbsp;<i class=\"icon-caret-down\"></i>\n    </span>\n  </button>\n\n\n  <!-- <button class=\"btn btn-default\" ng-hide=\"item.status == 'opas_invisible'\" ng-class=\"{'active btn-warning': item.status == 'passcode' }\" ng-click=\"item.status = 'passcode'; status_process()\" type=\"button\" ng-switch on=\"item[field]\">\n    <div class=\"extra\">\n      <i class=\"icon-lock\"></i>\n    </div>\n    <span ng-switch-when=\"passcode\">{{ 'Private' | i18next }}</span>\n    <span ng-switch-when=\"published\">{{ 'Make private' | i18next }}</span>\n  </button>\n\n\n  <button class=\"btn btn-default\" ng-show=\"item.status == 'opas_invisible'\" ng-class=\"{'active btn-danger': item.status == 'opas_invisible' }\" ng-click=\"item.status = 'opas_invisible'; status_process()\" type=\"button\">\n    <div class=\"extra\">\n      <i class=\"icon-eye-close\"></i>\n    </div>\n    <span>{{ 'Invisible' | i18next }}</span>\n  </button> -->\n\n\n  <!-- <button class=\"btn btn-default dropdown-toggle\">\n    <span>\n      <i class=\"icon-caret-down\"></i>\n    </span>\n  </button> -->\n  <ul class=\"dropdown-menu\">\n    <li ng-hide=\"item.status == 'published'\">\n      <a href=\"#\" ng-click=\"item.status = 'published'; status_process()\">\n        <i class=\"icon-globe\"></i> &nbsp;{{ 'Publish' | i18next }}\n      </a>\n    </li>\n    <li ng-hide=\"item.status == 'passcode'\">\n      <a href=\"#\" ng-click=\"item.status = 'passcode'; status_process()\">\n        <i class=\"icon-lock\"></i> &nbsp;&nbsp;{{ 'Make private' | i18next }}\n      </a>\n    </li>\n    <li ng-hide=\"item.status == 'opas_invisible'\">\n      <a href=\"#\" ng-click=\"item.status = 'opas_invisible'; status_process()\">\n        <i class=\"icon-eye-close\"></i> {{ 'Make invisible' | i18next }}\n      </a>\n    </li>\n  </ul>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs, storySetValidation) {
        return $scope.status_process = function() {
          if ($scope.$parent.grouped_exhibits) {
            switch ($scope.item.status) {
              case 'published':
                $scope.$parent.grouped_positions.published = false;
                break;
              case 'passcode':
                $scope.$parent.grouped_positions.passcode = false;
                break;
              case 'opas_invisible':
                $scope.$parent.grouped_positions.invisible = false;
            }
            setTimeout(function() {
              return $scope.$parent.grid();
            }, 200);
            $scope.$parent.active_exhibit.reopen_dropdown = true;
            $scope.$parent.closeDropDown();
            setTimeout(function() {
              var target;
              target = $('li.exhibit.reopen > .opener');
              $scope.$parent.open_dropdown({
                target: target
              }, $scope.$parent.active_exhibit);
              return $scope.$parent.active_exhibit.reopen_dropdown = false;
            }, 500);
          }
          return storySetValidation.checkValidity($scope);
        };
      },
      link: function(scope, element, attrs) {
        scope.hidden_list = true;
        return true;
      }
    };
  }).directive("switchpub", function($timeout) {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        provider: '=ngProvider',
        field: '@field',
        field_type: '@type',
        root: '=root'
      },
      template: "<div class=\"btn-group pull-right\">\n  <button class=\"btn btn-default\" type=\"button\">\n    <div ng-switch on=\"item[field]\">\n      <i class=\"icon-globe\" ng-switch-when=\"published\" ng-click=\"item[field] = 'passcode'; status_process()\" ></i>\n      <i class=\"icon-lock\" ng-switch-when=\"passcode\" ng-click=\"item[field] = 'published'; status_process()\" ></i>\n      <i class=\"icon-eye-close\" ng-switch-when=\"opas_invisible\" ng-click=\"item[field] = 'published'; status_process()\" ></i>\n    </div>\n  </button>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs, storySetValidation) {
        return $scope.status_process = function() {
          return storySetValidation.checkValidity($scope);
        };
      },
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive("newLangSwitch", function($rootScope) {
    return {
      restrict: "E",
      replace: true,
      scope: {
        museum: '=museum'
      },
      template: "<div class=\"form-group\">\n  <label class=\"col-xs-2 control-label\" for=\"museum_language_select\">{{ 'Language' | i18next }}</label>\n  <div class=\"help ng-scope\" popover=\"{{ 'Select language' | i18next }}\" popover-animation=\"true\" popover-placement=\"bottom\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  <div class=\"col-xs-6 triggered\">\n    <select class=\"form-control\" ng-model=\"museum.language\">\n      <option disabled=\"\" selected=\"\" value=\"dummy\">{{ 'Select a new language' | i18next }}</option>\n      <option value=\"{{translation}}\" ng-repeat=\"(translation, lang) in $parent.$parent.translations\">{{translation | i18next }}</option>\n    </select>\n </div>\n</div>",
      controller: function($scope, $element, $attrs) {
        return true;
      },
      link: function(scope, element, attrs) {
        scope.$watch('museum.language', function(newValue, oldValue) {
          if (newValue != null) {
            if (newValue !== 'new_lang') {
              return console.log('select', newValue);
            }
          }
        });
        return true;
      }
    };
  }).directive("placeholderfield", function($timeout) {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField',
        inv_sign: '=invalidsign',
        placeholder: '=placeholder',
        field_type: '@type'
      },
      template: "<div class=\"form-group textfield {{field}}\">\n  <label class=\"col-xs-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">\n    {{title}}\n    <span class=\"label label-danger informer\" ng-show=\"empty_name_error\">{{ \"can't be empty\" | i18next }}</span>\n  </label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  {{active_exhibit}}\n  <div class=\"col-xs-7 trigger\">\n    <span class=\"placeholder\" ng-click=\"update_old()\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-xs-7 triggered\">\n    <input type=\"hidden\" id=\"original_{{id}}\" ng-model=\"item[field]\" required>\n    <input type=\"text\" class=\"form-control\" id=\"{{id}}\" value=\"{{item[field]}}\" placeholder=\"{{placeholder}}\">\n    <div class=\"additional_controls\">\n      <a href=\"#\" class=\"apply\"><i class=\"icon-ok\"></i></a>\n      <!--<a href=\"#\" class=\"cancel\"><i class=\"icon-remove\"></i></a>-->\n    </div>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.field];
        $scope.update_old = function() {
          return $scope.oldValue = $scope.item[$scope.field];
        };
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] !== $scope.oldValue) {
            $scope.status = 'progress';
            $scope.$digest();
            if ($scope.$parent.new_item_creation && $scope.field === 'name') {
              if ($scope.item[$scope.field] && $scope.item[$scope.field].length !== 0) {
                $rootScope.$broadcast('save_new_exhibit');
                return true;
              }
            }
            if ($scope.field === 'name' && $scope.item.status === 'draft') {
              $scope.item.status = 'passcode';
            }
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
      link: function(scope, element, attrs) {
        var additional, control, trigger, triggered;
        element = $(element);
        trigger = element.find('.trigger');
        triggered = element.find('.triggered');
        control = element.find('.triggered > .form-control');
        additional = triggered.find('.additional_controls');
        scope.empty_name_error = false;
        element.find('span.placeholder').click(function() {
          trigger.hide();
          triggered.show();
          control.val(scope.item[scope.field]);
          control.focus();
          return control.removeClass('ng-invalid');
        });
        element.find('.triggered > .form-control').focus(function() {
          return additional.show();
        });
        element.find('.triggered > .form-control').blur(function() {
          var elem, value;
          elem = $(this);
          value = elem.val();
          additional.hide();
          return $timeout(function() {
            if (!(scope.$parent.new_item_creation && scope.field === 'number')) {
              scope.item[scope.field] = value;
              scope.$digest();
              if (elem.val().length > 0) {
                scope.status_process();
              } else {
                return true;
              }
            }
            if (elem.val().length > 0) {
              triggered.hide();
              return trigger.show();
            } else {
              elem.addClass('ng-invalid');
              if (scope.field === 'name' && scope.item.status !== 'dummy') {
                elem.val(scope.oldValue);
                scope.item[scope.field] = scope.oldValue;
                scope.$digest();
                triggered.hide();
                trigger.show();
                if (scope.item[scope.field] !== '') {
                  return scope.status_process();
                }
              }
            }
          }, 100);
        });
        element.find('.triggered > .form-control').keyup(function() {
          var elem, val;
          elem = $(this);
          val = elem.val();
          if (val === '' && scope.field === 'name' && scope.item[scope.field] !== '') {
            $timeout(function() {
              elem.val(scope.oldValue);
              scope.item[scope.field] = scope.oldValue;
              scope.empty_name_error = true;
              scope.$digest();
              setTimeout(function() {
                scope.empty_name_error = false;
                return scope.$digest();
              }, 2000);
              return scope.status_process();
            }, 0, false);
          }
          return true;
        });
        scope.$watch('item[field]', function(newValue, oldValue) {
          var criteria;
          scope.status = '';
          criteria = scope.field === 'number' ? newValue != null : newValue;
          if (!criteria) {
            additional.hide();
            trigger.hide();
            triggered.show();
            control.val('');
            if (scope.field === 'name') {
              return triggered.find('.form-control').focus();
            }
          } else {
            additional.show();
            element.find('.triggered > .form-control').val(newValue);
            trigger.show();
            return triggered.hide();
          }
        });
        return true;
      }
    };
  }).directive("placeholdertextarea", function($timeout, storySetValidation, $i18next) {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField',
        max_length: '@maxlength',
        placeholder: '=placeholder',
        field_type: '@type'
      },
      template: "<div class=\"form-group textfield large_field\">\n  <label class=\"col-xs-2 control-label\" for=\"{{id}}\" ng-click=\"edit_mode = false\">\n    {{title}}\n    <span class=\"label label-danger\" ng-show=\"field == 'long_description' && item[field].length == 0\">{{ \"Fill to publish\" | i18next }}</span>\n  </label>\n  <div class=\"help\" popover=\"{{help}}\" popover-placement=\"bottom\" popover-animation=\"true\" popover-trigger=\"mouseenter\">\n    <i class=\"icon-question-sign\"></i>\n  </div>\n  <div class=\"col-xs-7 trigger\">\n    <div class=\"placeholder large\" ng-click=\"update_old()\">{{item[field]}}</div>\n  </div>\n  <div class=\"col-xs-7 triggered\">\n    <input type=\"hidden\" id=\"original_{{id}}\" ng-model=\"item[field]\" required\">\n    <div class=\"content_editable\" contenteditable=\"true\" id=\"{{id}}\" placeholder=\"{{placeholder}}\">{{item[field]}}</div>\n    <div class=\"additional_controls\">\n      <a href=\"#\" class=\"apply\"><i class=\"icon-ok\"></i></a>\n      <!--<a href=\"#\" class=\"cancel\"><i class=\"icon-remove\"></i></a>-->\n    </div>\n  </div>\n  <span class=\"sumbols_left\">\n    {{length_text}}\n  </span>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.field];
        $scope.update_old = function() {
          return $scope.oldValue = $scope.item[$scope.field];
        };
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] !== $scope.oldValue) {
            $scope.status = 'progress';
            $scope.$digest();
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
      link: function(scope, element, attrs) {
        var additional, control, sumbols_left, trigger, triggered;
        scope.length_text = "" + scope.max_length + " symbols left";
        scope.max_length || (scope.max_length = 2000);
        element = $(element);
        trigger = element.find('.trigger');
        triggered = element.find('.triggered');
        sumbols_left = element.find('.sumbols_left');
        control = triggered.children('.content_editable');
        additional = triggered.find('.additional_controls');
        element.find('div.placeholder').click(function() {
          trigger.hide();
          triggered.show();
          control.text(scope.item[scope.field]);
          control.focus();
          scope.length_text = "" + (scope.max_length - control.text().length) + " " + ($i18next('symbols left'));
          return sumbols_left.show();
        });
        control.focus(function() {
          sumbols_left.show();
          return additional.show();
        });
        control.blur(function() {
          var elem;
          elem = $(this);
          sumbols_left.hide();
          scope.item[scope.field] = elem.text();
          scope.$digest();
          scope.status_process();
          if (elem.text() !== '') {
            triggered.hide();
            trigger.show();
            return scope.status_process();
          } else {
            return additional.hide();
          }
        });
        control.keyup(function(e) {
          var elem, value;
          elem = $(this);
          value = elem.text();
          if (value.length > scope.max_length) {
            elem.text(value.substr(0, scope.max_length));
          }
          scope.length_text = "" + (scope.max_length - value.length) + " " + ($i18next('symbols left'));
          return scope.$digest();
        });
        scope.$watch('item[field]', function(newValue, oldValue) {
          scope.max_length || (scope.max_length = 2000);
          if (!newValue) {
            scope.length_text = "2000 " + ($i18next('symbols left'));
            control.text('');
            trigger.hide();
            triggered.show();
            additional.hide();
            if (scope.field === 'long_description') {
              return storySetValidation.checkValidity({
                item: scope.item,
                root: scope.$parent.active_exhibit,
                field_type: 'story'
              });
            }
          } else {
            additional.show();
            scope.length_text = "" + (scope.max_length - newValue.length) + " " + ($i18next('symbols left'));
            if (scope.$parent.element_switch === true) {
              trigger.show();
              triggered.hide();
              sumbols_left.hide();
            }
            return true;
          }
        });
        return true;
      }
    };
  }).directive("quizanswer", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        collection: '=ngCollection',
        id: '@ngId',
        field: '@field',
        field_type: '@type'
      },
      template: "<div class=\"form-group textfield string optional checkbox_added\">\n  <label class=\"string optional control-label col-xs-2\" for=\"{{id}}\">\n    <span class='correct_answer_indicator'>{{ \"correct\" | i18next }}</span>\n  </label>\n  <input class=\"coorect_answer_radio\" name=\"correct_answer\" type=\"radio\" value=\"{{item._id}}\" ng-model=\"checked\" ng-click=\"check_items(item)\">\n  <div class=\"col-xs-5 trigger\">\n    <span class=\"placeholder\" ng-click=\"update_old()\">{{item[field]}}</span>\n  </div>\n  <div class=\"col-xs-5 triggered\">\n    <input class=\"form-control\" id=\"{{id}}\" name=\"{{item._id}}\" placeholder=\"Enter option\" type=\"text\" ng-model=\"item[field]\" required>\n    <div class=\"error_text\">{{ \"can't be blank\" | i18next }}</div>\n  </div>\n  <status-indicator ng-binding=\"status\"></statusIndicator>\n</div>",
      controller: function($scope, $rootScope, $element, $attrs) {
        if ($scope.item.statuses == null) {
          $scope.item.statuses = {};
        }
        $scope.status = $scope.item.statuses[$scope.item.content];
        if ($scope.item.correct_saved == null) {
          $scope.item.correct_saved = false;
        }
        $scope.check_items = function(item) {
          return $rootScope.$broadcast('quiz_changes_to_save', $scope, item);
        };
        $scope.update_old = function() {
          return $scope.oldValue = $scope.item[$scope.field];
        };
        return $scope.status_process = function() {
          if ($scope.item[$scope.field] !== $scope.oldValue) {
            $scope.status = 'progress';
            $scope.$digest();
            return $rootScope.$broadcast('changes_to_save', $scope);
          }
        };
      },
      link: function(scope, element, attrs) {
        var indicator, trigger, triggered;
        element = $(element);
        trigger = element.find('.trigger');
        triggered = element.find('.triggered');
        indicator = element.find('.correct_answer_indicator');
        element.find('span.placeholder').click(function() {
          trigger.hide();
          return triggered.show().children().first().focus();
        });
        element.find('.triggered > *').blur(function() {
          var elem;
          elem = $(this);
          scope.status_process();
          if (elem.val() !== '') {
            triggered.hide();
            return trigger.show();
          }
        });
        scope.$watch('collection', function(newValue, oldValue) {
          var single_item, _i, _len, _results;
          if (newValue) {
            scope.checked = newValue[0]._id;
            _results = [];
            for (_i = 0, _len = newValue.length; _i < _len; _i++) {
              single_item = newValue[_i];
              if (single_item.correct === true) {
                _results.push(scope.checked = single_item._id);
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          }
        });
        scope.$watch('item.content', function(newValue, oldValue) {
          if (!newValue) {
            trigger.hide();
            return triggered.show();
          } else {
            if (scope.$parent.element_switch === true) {
              trigger.show();
              return triggered.hide();
            }
          }
        });
        return scope.$watch('item.correct_saved', function(newValue, oldValue) {
          if (newValue === true) {
            indicator.show();
            return setTimeout(function() {
              indicator.hide();
              return scope.$apply(scope.item.correct_saved = false);
            }, 1000);
          }
        }, true);
      }
    };
  }).directive("statusIndicator", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngBinding',
        field: '=ngField'
      },
      template: "<div class=\"statuses\">\n  <div class='preloader' ng-show=\"item=='progress'\"></div>\n  <div class=\"save_status\" ng-show=\"item=='done'\">\n    <i class=\"icon-ok-sign\"></i>{{ \"saved\" | i18next }}\n  </div>\n</div>",
      link: function(scope, element, attrs) {
        scope.$watch('item', function(newValue, oldValue) {
          if (newValue) {
            if (newValue === 'progress') {
              scope.progress_timeout = setTimeout(function() {
                return scope.$apply(scope.item = 'done');
              }, 500);
            }
            if (newValue === 'done') {
              return scope.done_timeout = setTimeout(function() {
                return scope.$apply(scope.item = '');
              }, 700);
            }
          } else {
            clearTimeout(scope.done_timeout);
            return clearTimeout(scope.progress_timeout);
          }
        }, true);
        return true;
      }
    };
  }).directive("audioplayer", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField',
        parent: '=parent'
      },
      template: "<div class=\"form-group audio\">\n  <label class=\"col-xs-2 control-label\" for=\"audio\">\n    {{ \"Audio\" | i18next }}\n    <span class=\"label label-danger\" ng-show=\"edit_mode == 'empty'\">{{ \"Fill to publish\" | i18next }}</span>\n  </label>\n  <div class=\"help\">\n    <i class=\"icon-question-sign\" data-content=\"{{ \"Supplementary field.\" | i18next }}\" data-placement=\"bottom\"></i>\n  </div>\n  <div class=\"col-xs-9 trigger\" ng-show=\"edit_mode == 'value'\">\n    <div class=\"jp-jplayer\" id=\"jquery_jplayer_{{id}}\">\n    </div>\n    <div class=\"jp-audio\" id=\"jp_container_{{id}}\">\n      <div class=\"jp-type-single\">\n        <div class=\"jp-gui jp-interface\">\n          <ul class=\"jp-controls\">\n            <li>\n            <a class=\"jp-play\" href=\"javascript:;\" tabindex=\"1\"></a>\n            </li>\n            <li>\n            <a class=\"jp-pause\" href=\"javascript:;\" tabindex=\"1\"></a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"jp-timeline\">\n          <div class=\"dropdown\">\n            <a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\" id=\"visibility_filter\">{{item[field].name}}<span class=\"caret\"></span></a>\n            <ul class=\"dropdown-menu\" role=\"menu\">\n              <li role=\"presentation\">\n                <a href=\"#\" class=\"replace_media\" data-confirm=\"Are you sure you wish to replace this audio?\" data-method=\"delete\" data-link=\"{{$parent.$parent.backend_url}}/media/{{item[field]._id}}\">Replace</a>\n              </li>\n              <li role=\"presentation\">\n                <a href=\"{{item[field].url}}\" target=\"_blank\">Download</a>\n              </li>\n              <li role=\"presentation\">\n                <a class=\"remove\" href=\"#\" data-confirm=\"Are you sure you wish to delete this audio?\" data-method=\"delete\" data-link=\"{{$parent.$parent.backend_url}}/media/{{media._id}}\" delete-media=\"\" stop-event=\"\" media=\"item[field]\" parent=\"item\">Delete</a>\n              </li>\n            </ul>\n          </div>\n          <div class=\"jp-progress\">\n            <div class=\"jp-seek-bar\">\n              <div class=\"jp-play-bar\">\n              </div>\n            </div>\n          </div>\n          <div class=\"jp-time-holder\">\n            <div class=\"jp-current-time\">\n            </div>\n            <div class=\"jp-duration\">\n            </div>\n          </div>\n          <div class=\"jp-no-solution\">\n            <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href=\"http://get.adobe.com/flashplayer/\" target=\"_blank\"></a>\n          </div>\n        </div>\n      </div>\n    </div>\n  </div>\n  <div class=\"triggered\" ng-show=\"edit_mode == 'empty'\">\n    <img class=\"upload_audio\" src=\"/img/audio_drag.png\" />\n    <span>drag audio here or </span>\n    <a href=\"#\" class=\"btn btn-default\" button-file-upload=\"\">Click to upload</a>\n  </div>\n  <div class=\"col-xs-9 processing\" ng-show=\"edit_mode == 'processing'\">\n    <img class=\"upload_audio\" src=\"/img/medium_loader.GIF\" style=\"float: left;\"/> \n    <span>{{ \"&nbsp;&nbsp;processing audio\" | i18next }}</span>\n  </div>\n  <status-indicator ng-binding=\"item\" ng-field=\"field\"></statusIndicator>\n</div>",
      link: function(scope, element, attrs) {
        scope.edit_mode = false;
        element = $(element);
        element.find('.replace_media').click(function(e) {
          var elem, input, parent;
          e.preventDefault();
          e.stopPropagation();
          elem = $(this);
          parent = elem.parents('#drop_down, #museum_drop_down');
          parent.click();
          input = parent.find('input:file');
          return input.click();
        });
        scope.$watch('item[field]', function(newValue, oldValue) {
          if (!newValue) {
            return scope.edit_mode = 'empty';
          } else if (newValue === 'processing') {
            return scope.edit_mode = 'processing';
          } else {
            scope.edit_mode = 'value';
            $("#jquery_jplayer_" + scope.id).jPlayer({
              cssSelectorAncestor: "#jp_container_" + scope.id,
              swfPath: "/js",
              wmode: "window",
              preload: "auto",
              smoothPlayBar: true,
              supplied: "mp3, ogg"
            });
            return $("#jquery_jplayer_" + scope.id).jPlayer("setMedia", {
              mp3: newValue.url,
              ogg: newValue.thumbnailUrl
            });
          }
        });
        return true;
      }
    };
  }).directive("player", function() {
    return {
      restrict: "E",
      replace: true,
      require: "?ngModel",
      scope: {
        item: '=ngItem',
        help: '@ngHelp',
        id: '@ngId',
        title: '@ngTitle',
        field: '@ngField',
        container: '=container'
      },
      template: "<div class=\"player\">\n  <div class=\"jp-jplayer\" id=\"jquery_jplayer_{{id}}\">\n  </div>\n  <div class=\"jp-audio\" id=\"jp_container_{{id}}\">\n    <div class=\"jp-type-single\">\n      <div class=\"jp-gui jp-interface\">\n        <ul class=\"jp-controls\">\n          <li>\n          <a class=\"jp-play\" href=\"javascript:;\" tabindex=\"1\"></a>\n          </li>\n          <li>\n          <a class=\"jp-pause\" href=\"javascript:;\" tabindex=\"1\"></a>\n          </li>\n        </ul>\n      </div>\n      <div class=\"jp-timeline\">\n        <a class=\"dropdown-toggle\" href=\"#\">&nbsp;</a>\n        <div class=\"jp-progress\">\n          <div class=\"jp-seek-bar\">\n            <div class=\"jp-play-bar\">\n            </div>\n          </div>\n        </div>\n        <div class=\"jp-time-holder\">\n          <div class=\"jp-current-time\">\n          </div>\n          <div class=\"jp-duration\">\n          </div>\n        </div>\n        <div class=\"jp-no-solution\">\n          <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href=\"http://get.adobe.com/flashplayer/\" target=\"_blank\"></a>\n        </div>\n      </div>\n    </div>\n  </div>\n  <div class=\"points_position_holder\">\n    <div class=\"image_connection\" ng-class=\"{'hovered': image.image.hovered}\" data-image-index=\"{{$index}}\" js-draggable ng-repeat=\"image in container.stories[$parent.current_museum.language].mapped_images\" ng-mouseenter=\"set_hover(image, true)\" ng-mouseout=\"set_hover(image, false)\">\n      {{ charFromNum(image.image.order) }}\n    </div>\n  </div>\n</div>",
      controller: function($scope, $element, $attrs) {
        $scope.charFromNum = function(num) {
          return String.fromCharCode(num + 97).toUpperCase();
        };
        return $scope.set_hover = function(image, sign) {
          var sub_sign;
          sub_sign = sign ? sign : image.dragging ? true : sign;
          image.image.hovered = sub_sign;
          return $scope.container.has_hovered = sub_sign;
        };
      },
      link: function(scope, element, attrs) {
        scope.$watch('item[field]', function(newValue, oldValue) {
          if (newValue) {
            $("#jquery_jplayer_" + scope.id).jPlayer({
              cssSelectorAncestor: "#jp_container_" + scope.id,
              swfPath: "/js",
              wmode: "window",
              preload: "auto",
              smoothPlayBar: true,
              supplied: "mp3, ogg"
            });
            return $("#jquery_jplayer_" + scope.id).jPlayer("setMedia", {
              mp3: newValue.url,
              ogg: newValue.thumbnailUrl
            });
          } else {
            return console.log('no audio');
          }
        });
        return true;
      }
    };
  }).directive("museumSearch", function() {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      require: "?ngModel",
      scope: {
        item: '=ngModel'
      },
      template: "<div class=\"searches\">\n  <div class=\"search\" ng-hide=\"museum_search_visible\" ng-click=\"museum_search_visible=true; museum_input_focus = true\">\n    <i class=\"icon-search\"></i>\n    <a href=\"#\">{{item || 'Search' | i18next }}</a>\n  </div>\n  <div class=\"search_input\" ng-show=\"museum_search_visible\">\n    <input class=\"form-control\" ng-model=\"item\" placeholder=\"{{ \"Search\" | i18next }}\" type=\"text\" focus-me=\"museum_input_focus\">\n    <a class=\"search_reset\" href=\"#\" ng-click=\"item=''\">\n      <i class=\"icon-remove-sign\"></i>\n    </a>\n  </div>\n</div>",
      controller: function($scope, $element) {
        $scope.museum_search_visible = false;
        $scope.museum_input_focus = false;
        $($element).find('.search_input input').blur(function() {
          var elem;
          elem = $(this);
          $scope.$apply($scope.museum_input_focus = false);
          return elem.animate({
            width: '150px'
          }, 150, function() {
            $scope.$apply($scope.museum_search_visible = false);
            return true;
          });
        });
        return $($element).find('.search_input input').focus(function() {
          var input, width;
          input = $(this);
          width = $('body').width() - 700;
          if (width > 150) {
            return input.animate({
              width: "" + width + "px"
            }, 300);
          }
        });
      },
      link: function(scope, element, attrs) {
        return true;
      }
    };
  }).directive('canDragAndDrop', function(errorProcessing, $i18next) {
    return {
      restrict: 'A',
      scope: {
        model: '=model',
        url: '@uploadTo',
        selector: '@selector',
        selector_dropzone: '@selectorDropzone'
      },
      link: function(scope, element, attrs) {
        var checkExtension, correctFileSize, dropzone, fileSizeMb, file_types, hide_drop_area, initiate_progress;
        scope.$parent.loading_in_progress = false;
        fileSizeMb = 50;
        element = $("#" + scope.selector);
        dropzone = $("#" + scope.selector_dropzone);
        checkExtension = function(object) {
          var extension, type;
          if (object.files[0].name != null) {
            extension = object.files[0].name.split('.').pop().toLowerCase();
            type = 'unsupported';
            if ($.inArray(extension, gon.acceptable_extensions.image) !== -1) {
              type = 'image';
            }
            if ($.inArray(extension, gon.acceptable_extensions.audio) !== -1) {
              type = 'audio';
            }
            if ($.inArray(extension, gon.acceptable_extensions.video) !== -1) {
              type = 'video';
            }
          } else {
            type = object.files[0].type.split('/')[0];
            object.files[0].subtype = object.files[0].type.split('/')[1];
          }
          return type;
        };
        correctFileSize = function(object) {
          return object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024;
        };
        hide_drop_area = function() {
          $(".progress").hide();
          return setTimeout(function() {
            $("body").removeClass("in");
            scope.$parent.loading_in_progress = false;
            return scope.$parent.forbid_switch = false;
          }, 1000);
        };
        initiate_progress = function() {
          scope.$parent.loading_in_progress = true;
          scope.$parent.forbid_switch = true;
          scope.$digest();
          $("body").addClass("in");
          $(".progress .progress-bar").css("width", 0 + "%");
          return $(".progress").show();
        };
        file_types = [];
        element.fileupload({
          url: scope.url,
          dataType: "json",
          dropZone: dropzone,
          change: function(e, data) {
            return initiate_progress();
          },
          drop: function(e, data) {
            initiate_progress();
            return $.each(data.files, function(index, file) {
              return console.log("Dropped file: " + file.name);
            });
          },
          add: function(e, data) {
            var parent, type;
            type = checkExtension(data);
            if (type === 'image' || type === 'audio' || type === 'video') {
              if (correctFileSize(data)) {
                file_types.push(type);
                parent = scope.model._id;
                if (type === 'audio' || type === 'video') {
                  parent = scope.model.stories[scope.$parent.current_museum.language]._id;
                }
                data.formData = {
                  type: type,
                  parent: parent
                };
                data.submit();
                if (type === 'audio') {
                  return scope.model.stories[scope.$parent.current_museum.language].audio = 'processing';
                }
              } else {
                errorProcessing.addError($i18next('File is bigger than 50mb'));
                return hide_drop_area();
              }
            } else {
              errorProcessing.addError($i18next('Unsupported file type'));
              return hide_drop_area();
            }
          },
          success: function(result) {
            var file, new_image, _i, _len, _results;
            _results = [];
            for (_i = 0, _len = result.length; _i < _len; _i++) {
              file = result[_i];
              if (file.type === 'image') {
                if (scope.model.images == null) {
                  scope.model.images = [];
                }
                new_image = {};
                new_image.image = file;
                new_image.mappings = {};
                if (file.cover === true) {
                  scope.$apply(scope.model.cover = file);
                }
                scope.$apply(scope.model.images.push(new_image));
              } else if (file.type === 'audio') {
                scope.$apply(scope.model.stories[scope.$parent.current_museum.language].audio = file);
              } else if (file.type === 'video') {
                scope.$apply(scope.model.stories[scope.$parent.current_museum.language].video = file);
              }
              _results.push(scope.$digest());
            }
            return _results;
          },
          error: function(result, status, errorThrown) {
            var response, responseText;
            if (errorThrown === 'abort') {
              errorProcessing.addError($i18next('Uploading aborted'));
            } else {
              if (result.status === 422) {
                response = jQuery.parseJSON(result.responseText);
                responseText = response.link[0];
                rrorProcessing.addError($i18next('Error during file upload. Prototype error'));
              } else {
                errorProcessing.addError($i18next('Error during file upload. Prototype error'));
              }
            }
            errorProcessing.addError($i18next('Error during file upload. Prototype error'));
            return hide_drop_area();
          },
          progressall: function(e, data) {
            var delimiter, progress, speed, speed_text, types;
            progress = parseInt(data.loaded / data.total * 100, 10);
            delimiter = 102.4;
            speed = Math.round(data.bitrate / delimiter) / 10;
            speed_text = "" + speed + " Кб/с";
            if (speed > 1000) {
              speed = Math.round(speed / delimiter) / 10;
              speed_text = "" + speed + " Мб/с";
            }
            $(".progress .progress-text").html("" + ($i18next('&nbsp;&nbsp; Uploaded')) + " " + (Math.round(data.loaded / 1024)) + " " + ($i18next('Kb of')) + " " + (Math.round(data.total / 1024)) + " " + ($i18next('Kb, speed:')) + " " + speed_text);
            $(".progress .progress-bar").css("width", progress + "%");
            if (data.loaded === data.total) {
              scope.$parent.last_save_time = new Date();
              types = file_types.unique();
              console.log(types);
              if (types.length === 1 && types[0] === 'audio') {
                console.log('file type is audio');
              } else {
                setTimeout(function() {
                  var first_image;
                  first_image = element.parents('li').find('ul.images li.dragable_image a.img_thumbnail').last();
                  return first_image.click();
                }, 1000);
              }
              element.parents('li').find('ul.images .museum_image_placeholder').hide();
              file_types = [];
              return hide_drop_area();
            }
          }
        }).prop("disabled", !$.support.fileInput).parent().addClass(($.support.fileInput ? undefined : "disabled"));
        return scope.$watch('url', function(newValue, oldValue) {
          if (newValue) {
            return element.fileupload("option", "url", newValue);
          }
        });
      }
    };
  }).directive("buttonFileUpload", function() {
    return {
      restrict: "A",
      link: function(scope, element, attr) {
        var elem;
        elem = $(element);
        return elem.click(function(e) {
          var parent;
          e.preventDefault();
          elem = $(this);
          parent = elem.parents('#drop_down, #museum_edit_dropdown');
          return parent.find(':file').click();
        });
      }
    };
  }).directive('deleteMedia', function(storySetValidation, $http) {
    return {
      restrict: 'A',
      scope: {
        model: '=parent',
        media: '=media'
      },
      link: function(scope, element, attrs) {
        var delete_overlay;
        element = $(element);
        delete_overlay = element.next('.delete_overlay');
        return element.click(function(e) {
          var confirm_text, delete_media_function, elem, show_overlay, silent;
          e.preventDefault();
          e.stopPropagation();
          elem = $(this);
          confirm_text = elem.data('confirm');
          show_overlay = elem.data('show-overlay');
          silent = elem.data('silent-delete');
          delete_media_function = function() {
            return $http["delete"](elem.data('link')).success(function(data) {
              var image, index, lang, mapping, new_cover, parent, _i, _j, _len, _len1, _ref, _ref1;
              if (show_overlay) {
                delete_overlay.hide();
                delete_overlay.find('.preloader').hide();
                delete_overlay.find('.overlay_controls, span').show();
              }
              if (scope.media.type === 'image') {
                _ref = scope.model.images;
                for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
                  image = _ref[index];
                  if (image != null) {
                    if (image.image._id === data._id) {
                      scope.model.images.splice(index, 1);
                      if (image.image.cover === true) {
                        new_cover = scope.model.images[0];
                        new_cover.image.cover = true;
                        scope.model.cover = new_cover.image;
                        $http.put("" + scope.$parent.$parent.$parent.backend_url + "/media/" + new_cover.image._id, new_cover.image).success(function(data) {
                          return console.log('ok');
                        }).error(function() {
                          return console.log('bad');
                        });
                      }
                    }
                  }
                }
                if (scope.model.images.length === 0 && scope.model.stories[scope.$parent.$parent.$parent.current_museum.language].status === 'published') {
                  storySetValidation.checkValidity({
                    item: scope.model.stories[scope.$parent.$parent.$parent.current_museum.language],
                    root: scope.model,
                    field_type: 'story'
                  });
                }
              } else if (scope.media.type === 'audio') {
                parent = scope.$parent.$parent.active_exhibit;
                lang = scope.$parent.$parent.current_museum.language;
                scope.model.audio = void 0;
                scope.model.mapped_images = [];
                scope.$parent.$parent.exhibit_timline_opened = false;
                _ref1 = parent.images;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  image = _ref1[_j];
                  mapping = image.mappings[lang];
                  if (mapping != null) {
                    delete image.mappings[lang];
                    $http["delete"]("" + scope.$parent.$parent.backend_url + "/media_mapping/" + mapping._id).success(function(data) {
                      return console.log(data);
                    }).error(function() {
                      return errorProcessing.addError($i18next('Failed to delete timestamp'));
                    });
                  }
                }
                scope.$digest();
                if (scope.model.status === 'published') {
                  storySetValidation.checkValidity({
                    item: scope.model,
                    root: parent,
                    field_type: 'story'
                  });
                }
              }
              return scope.$parent.last_save_time = new Date();
            });
          };
          if (show_overlay) {
            delete_overlay.show();
            delete_overlay.find('.delete').unbind('click').bind('click', function(e) {
              delete_overlay.find('.preloader').show();
              delete_overlay.find('.overlay_controls, span').hide();
              delete_media_function();
              return e.preventDefault();
            });
            return delete_overlay.find('.btn-sm.cancel').unbind('click').bind('click', function(e) {
              delete_overlay.hide();
              return e.preventDefault();
            });
          } else if (silent) {
            return delete_media_function();
          } else {
            if (confirm(confirm_text)) {
              return delete_media_function();
            }
          }
        });
      }
    };
  }).directive('dragAndDropInit', function(uploadHelpers) {
    return {
      link: function(scope, element, attrs) {
        $(document).bind('drop dragover', function(e) {
          return e.preventDefault();
        });
        $(document).bind("dragover", function(e) {
          var doc, dropZone, found, found_index, node, timeout;
          if ($(e.originalEvent.srcElement).hasClass('do_not_drop')) {
            e.preventDefault();
            e.stopPropagation();
            return false;
          }
          dropZone = $(".dropzone");
          doc = $("body");
          timeout = scope.dropZoneTimeout;
          if (!timeout) {
            doc.addClass("in");
          } else {
            clearTimeout(timeout);
          }
          found = false;
          found_index = 0;
          node = e.target;
          while (true) {
            if (node === dropZone[0]) {
              found = true;
              found_index = 0;
              break;
            } else if (node === dropZone[1]) {
              found = true;
              found_index = 1;
              break;
            }
            node = node.parentNode;
            if (node == null) {
              break;
            }
          }
          if (found) {
            return dropZone[found_index].addClass("hover");
          } else {
            return scope.dropZoneTimeout = setTimeout(function() {
              if (!scope.loading_in_progress) {
                scope.dropZoneTimeout = null;
                dropZone.removeClass("in hover");
                return doc.removeClass("in");
              }
            }, 300);
          }
        });
        return $(document).bind("drop", function(e) {
          var fileupload, img, type, url;
          fileupload = $(e.originalEvent.target).parents('li').find("input[type='file']");
          if (e.originalEvent.dataTransfer) {
            if ($(e.target).hasClass('do_not_drop')) {
              e.stopPropagation();
              e.preventDefault();
              return false;
            }
            url = $(e.originalEvent.dataTransfer.getData("text/html")).filter("img").attr("src");
            if (url) {
              if (url.indexOf('data:image') >= 0) {
                type = url.split(';base64')[0].split('data:')[1];
                img = new Image();
                img.src = url;
                return img.onload = function() {
                  return uploadHelpers.cavas_processor(img, type);
                };
              } else {
                return $.getImageData({
                  url: url,
                  server: "" + scope.backend_url + "/imagedata",
                  success: uploadHelpers.cavas_processor
                });
              }
            }
          }
        });
      }
    };
  }).directive('urlUpload', function($http, uploadHelpers) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var testRegex;
        element = $(element);
        testRegex = /^(http(s?):)|([/|.|\w|\s])*\.(?:jpg|jpeg|gif|png)?/;
        return element.bind('paste', function() {
          return setTimeout(function() {
            var type, url;
            url = element.val();
            if (testRegex.test(url)) {
              type = "image/" + (url.split('.').reverse()[0]);
              console.log('ok');
              element.parents('ul.images').find('.museum_image_placeholder').css({
                'display': 'inline-block'
              });
              return $.getImageData({
                url: url,
                server: "" + scope.$parent.backend_url + "/imagedata",
                success: function(img) {
                  element.val('');
                  return uploadHelpers.cavas_processor(img, type);
                }
              });
            } else {
              if (url !== '') {
                console.log('some error should be shown');
                element.addClass('error');
                return setTimeout(function() {
                  return element.removeClass('error');
                }, 1500);
              }
            }
          }, 10);
        });
      }
    };
  }).directive('dropDownEdit', function($timeout, $http) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var answers_watcher, name_watcher, qr_code_watcher, question_watcher, quiz_watcher;
        quiz_watcher = null;
        question_watcher = null;
        name_watcher = null;
        answers_watcher = null;
        qr_code_watcher = null;
        return scope.$watch('active_exhibit.stories[current_museum.language]', function(newValue, oldValue) {
          if (quiz_watcher != null) {
            quiz_watcher();
          }
          if (question_watcher != null) {
            question_watcher();
          }
          if (name_watcher != null) {
            name_watcher();
          }
          if (answers_watcher != null) {
            answers_watcher();
          }
          if (qr_code_watcher != null) {
            qr_code_watcher();
          }
          if (newValue != null) {
            quiz_watcher = scope.$watch('active_exhibit.stories[current_museum.language].quiz', function(newValue, oldValue) {
              if (newValue != null) {
                if (newValue !== oldValue) {
                  if (newValue.status === 'published') {
                    console.log('pub');
                    if (!$("#story_quiz_enabled").is(':checked')) {
                      return setTimeout(function() {
                        if (!scope.quizform.$valid) {
                          return setTimeout(function() {
                            return $("#story_quiz_disabled").click();
                          }, 10);
                        }
                      }, 100);
                    } else {
                      return setTimeout(function() {
                        return $("#story_quiz_enabled").click();
                      }, 10);
                    }
                  } else {
                    if (!$("#story_quiz_disabled").is(':checked')) {
                      return setTimeout(function() {
                        return $("#story_quiz_disabled").click();
                      }, 10);
                    }
                  }
                }
              }
            });
            question_watcher = scope.$watch('active_exhibit.stories[current_museum.language].quiz.question', function(newValue, oldValue) {
              if ((scope.quizform != null) && newValue !== oldValue) {
                if (scope.quizform.$valid) {
                  return scope.mark_quiz_validity(scope.quizform.$valid);
                } else {
                  return setTimeout(function() {
                    $("#story_quiz_disabled").click();
                    return scope.mark_quiz_validity(scope.quizform.$valid);
                  }, 10);
                }
              }
            });
            name_watcher = scope.$watch('active_exhibit.stories[current_museum.language].name', function(newValue, oldValue) {
              var form;
              if (newValue != null) {
                form = $('#media form');
                if (form.length > 0) {
                  if (scope.active_exhibit.stories[scope.current_museum.language].status === 'dummy') {
                    if (newValue) {
                      return scope.active_exhibit.stories[scope.current_museum.language].status = 'passcode';
                    }
                  } else {
                    if (!scope.new_item_creation) {
                      if (!newValue) {
                        scope.active_exhibit.stories[scope.current_museum.language].name = oldValue;
                        scope.empty_name_error = true;
                        return setTimeout(function() {
                          return scope.empty_name_error = false;
                        }, 1500);
                      }
                    }
                  }
                }
              }
            });
            answers_watcher = scope.$watch(function() {
              if (scope.active_exhibit.stories[scope.current_museum.language] != null) {
                return angular.toJson(scope.active_exhibit.stories[scope.current_museum.language].quiz.answers);
              } else {
                return void 0;
              }
            }, function(newValue, oldValue) {
              if (newValue != null) {
                if (scope.quizform != null) {
                  if (scope.quizform.$valid) {
                    return scope.mark_quiz_validity(scope.quizform.$valid);
                  } else {
                    return setTimeout(function() {
                      return $("#story_quiz_disabled").click();
                    }, 10);
                  }
                }
              }
            });
            return qr_code_watcher = scope.$watch('active_exhibit.stories[current_museum.language]', function(newValue, oldValue) {
              if (newValue) {
                if (!scope.active_exhibit.stories[scope.current_museum.language].qr_code) {
                  return $http.get("" + scope.backend_url + "/qr_code/" + scope.active_exhibit.stories[scope.current_museum.language]._id).success(function(d) {
                    return scope.active_exhibit.stories[scope.current_museum.language].qr_code = d;
                  });
                }
              }
            });
          }
        });
      }
    };
  }).directive('openLightbox', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var lightbox, parent;
        element = $(element);
        parent = element.parents('#drop_down, #museum_edit_dropdown');
        lightbox = parent.find('.lightbox_area');
        element.click(function() {
          if (element.parents('li').hasClass('dragged')) {
            return element.parents('li').removeClass('dragged');
          } else {
            lightbox.show();
            if (lightbox.height() + 45 > parent.height()) {
              parent.height(lightbox.height() + 45);
            }
            return setTimeout(function() {
              return $(".slider:visible .thumb.item_" + attrs.openLightbox + " img").click();
            }, 100);
          }
        });
        return true;
      }
    };
  }).directive('lightboxCropper', function($http, errorProcessing, $i18next) {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      scope: {
        model: '=model'
      },
      template: "<div class=\"lightbox_area\">\n  <ul class=\"nav nav-tabs\">\n    <li ng-class=\"{'active': story_tab == 'thumb'}\">\n      <a href=\"#\" ng-click=\"update_media(active_image_index); story_tab = 'thumb'\" >{{ 'Select thumbnail area' | i18next }}</a>\n    </li>\n    <li ng-class=\"{'active': story_tab == 'full'}\">\n      <a href=\"#\" ng-click=\"update_media(active_image_index); story_tab = 'full'\" >{{ 'Select fullsize image area' | i18next }}</a>\n    </li>        \n  </ul>\n    <button class=\"btn btn-warning apply_resize\" type=\"button\">{{ \"Done image editing\" | i18next }}</button>\n    <div class=\"lightbox_preloader\">\n      <img src=\"/img/big_loader_2.GIF\">\n    </div>\n    <div class=\"content {{story_tab}}\">\n      <div class=\"cropping_area {{story_tab}}\">\n        {{story_tab}}\n        <img class=\"cropper_thumb\" src=\"{{model.images[active_image_index].image.fullUrl || model.images[active_image_index].image.url}}\">\n        <img class=\"cropper_full\" src=\"{{model.images[active_image_index].image.url}}\">\n      </div>\n      <div class=\"notification\" ng-switch on=\"story_tab\">\n        <span ng-switch-when=\"thumb\">\n          {{ \"Select the preview area. Images won't crop. You can always return to this later on.\" | i18next }}\n        </span>\n        <span ng-switch-when=\"full\">\n          {{ \"Images won't crop. You can always return to this later on.\" | i18next }}\n        </span>\n      </div>\n      <div class=\"preview\" ng-hide=\"story_tab == 'full'\">\n        {{ \"Thumbnail preview\" | i18next }}\n        <div class=\"mobile\">\n          <div class=\"image\">\n            <img src=\"{{ model.images[active_image_index].image.fullUrl || model.images[active_image_index].image.url }}\">\n          </div>\n        </div>\n      </div>\n    </div>\n    <div class=\"slider\">\n      <ul class=\"images_sortable\" sortable=\"model.images\" lang=\"$parent.current_museum.language\">\n        <li class=\"thumb item_{{$index}} \" ng-class=\"{'active':image.image.active, 'timestamp': image.mappings[lang].timestamp >= 0}\" ng-repeat=\"image in images\">\n          <img ng-click=\"$parent.$parent.set_index($index)\" src=\"{{image.image.thumbnailUrl}}\" />\n          <div class=\"label_timestamp\" ng-show=\"image.mappings[lang].timestamp >= 0\">\n            <span class=\"letter_label\">\n              {{ image.image.order | numstring }}\n            </span>\n            <span class=\"time\">\n              {{ image.mappings[lang].timestamp | timerepr }}\n            </span>\n          </div>\n          <a class=\"cover pointer_events\" ng-class=\"{'active':image.image.cover}\" ng-click=\"$parent.$parent.make_cover($index)\" ng-switch on=\"image.image.cover\">\n            <span ng-switch-when=\"true\"><i class=\"icon-ok\"></i> {{ \"Cover\" | i18next }}</span>\n            <span ng-switch-default><i class=\"icon-ok\"></i> {{ \"Set cover\" | i18next }}</span>\n          </a>\n        </li>\n      </ul>\n    </div>\n</div>",
      controller: function($scope, $element, $attrs) {
        $scope.set_index = function(index, tab) {
          return $scope.update_media($scope.active_image_index, function() {
            $scope.active_image_index = index;
            if ((tab != null) && tab !== $scope.story_tab) {
              return $scope.story_tab = tab;
            }
          });
        };
        $scope.make_cover = function(index) {
          var image, _i, _len, _ref, _results;
          console.log('making a cover');
          $scope.model.cover = $scope.model.images[index].image;
          _ref = $scope.model.images;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            image = _ref[_i];
            if (image.image._id !== $scope.model.cover._id) {
              image.image.cover = false;
            } else {
              image.image.cover = true;
              $scope.model.cover = image.image;
              setTimeout((function() {
                return this.order = 0;
              }).bind(image.image)(), 500);
            }
            _results.push($http.put("" + $scope.$parent.backend_url + "/media/" + image.image._id, image.image).success(function(data) {
              return console.log('ok');
            }).error(function() {
              return errorProcessing.addError($i18next('Failed to set cover'));
            }));
          }
          return _results;
        };
        return $scope.check_active_image = function() {
          var image, index, _i, _len, _ref, _results;
          _ref = $scope.model.images;
          _results = [];
          for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
            image = _ref[index];
            _results.push(image.image.active = index === $scope.active_image_index ? true : false);
          }
          return _results;
        };
      },
      link: function(scope, element, attrs) {
        var bounds, content, cropper_full, cropper_thumb, done, getSelection, imageHeight, imageHeight_full, imageWidth, imageWidth_full, left, max_height, max_width, parent, preloader, prev_height, prev_width, preview, right, selected_full, selected_thumb, showPreview, update_selection;
        scope.story_tab = 'thumb';
        scope.img_url = '';
        element = $(element);
        preloader = element.find('.lightbox_preloader');
        content = element.find('.content');
        right = element.find('a.right');
        left = element.find('a.left');
        cropper_thumb = element.find('.cropping_area img.cropper_thumb');
        cropper_full = element.find('.cropping_area img.cropper_full');
        preview = element.find('.mobile .image img');
        done = element.find('.apply_resize');
        parent = element.parents('#drop_down, #museum_edit_dropdown');
        imageWidth = 0;
        imageWidth_full = 0;
        imageHeight_full = 0;
        imageHeight = 0;
        max_height = 330;
        max_width = 450;
        prev_height = 133;
        prev_width = 177;
        selected_thumb = {};
        selected_full = {};
        bounds = [];
        done.click(function() {
          scope.update_media(scope.active_image_index);
          scope.story_tab = 'thumb';
          parent.attr('style', '');
          element.hide();
          return false;
        });
        scope.update_media = function(index, callback) {
          var selected;
          console.log('updating media');
          if (scope.story_tab === 'full') {
            selected = selected_full;
            preloader.show();
            content.hide();
            console.log('hiding thumb');
          } else {
            selected = selected_thumb;
          }
          if (scope.model.images[scope.active_image_index] == null) {
            scope.active_image_index = 0;
          }
          return $http.put("" + scope.$parent.backend_url + "/resize_thumb/" + scope.model.images[scope.active_image_index].image._id, selected).success(function(data) {
            delete scope.model.images[index].image.url;
            delete scope.model.images[index].image.fullUrl;
            delete scope.model.images[index].image.selection;
            delete scope.model.images[index].image.full_selection;
            delete scope.model.images[index].image.thumbnailUrl;
            angular.extend(scope.model.images[index].image, data);
            if (callback) {
              callback();
            }
            return true;
          }).error(function() {
            errorProcessing.addError($i18next('Failed to update a thumbnail'));
            return false;
          });
        };
        showPreview = function(coords) {
          var rx, ry;
          selected_thumb = coords;
          selected_thumb.mode = 'thumb';
          rx = 177 / selected_thumb.w;
          ry = 133 / selected_thumb.h;
          return preview.css({
            width: Math.round(rx * bounds[0]) + "px",
            height: Math.round(ry * bounds[1]) + "px",
            marginLeft: "-" + Math.round(rx * selected_thumb.x) + "px",
            marginTop: "-" + Math.round(ry * selected_thumb.y) + "px"
          });
        };
        getSelection = function(selection) {
          var result;
          result = [selection.x, selection.y, selection.x2, selection.y2];
          return result;
        };
        update_selection = function(coords) {
          selected_full = coords;
          selected_full.mode = 'full';
          return true;
        };
        cropper_thumb.on('load', function() {
          console.log('thumb reloaded');
          preloader.hide();
          content.show();
          return setTimeout((function() {
            var new_imageHeight, new_imageWidth, options, selection, thumb_jcrop;
            imageWidth = cropper_thumb.get(0).naturalWidth;
            imageHeight = cropper_thumb.get(0).naturalHeight;
            new_imageWidth = imageWidth;
            new_imageHeight = imageHeight;
            if (imageHeight > max_height) {
              new_imageWidth = imageWidth * (max_height / imageHeight);
              new_imageHeight = max_height;
            }
            if (new_imageWidth > max_width) {
              new_imageHeight = new_imageHeight * (max_width / new_imageWidth);
              new_imageWidth = max_width;
            }
            cropper_thumb.height(new_imageHeight);
            cropper_thumb.width(new_imageWidth);
            preview.attr('style', "");
            selection = scope.model.images[scope.active_image_index].image.selection;
            if (selection) {
              selected_thumb = JSON.parse(selection);
            } else {
              selected_thumb = {
                x: 0,
                y: 0,
                w: imageWidth,
                h: imageHeight,
                x2: imageWidth,
                y2: imageHeight,
                mode: 'thumb'
              };
            }
            options = {
              boxWidth: cropper_thumb.width(),
              boxHeight: cropper_thumb.height(),
              setSelect: getSelection(selected_thumb),
              trueSize: [imageWidth, imageHeight],
              onChange: showPreview,
              onSelect: showPreview,
              aspectRatio: 4 / 3
            };
            if (this.thumb_jcrop) {
              this.thumb_jcrop.destroy();
            }
            thumb_jcrop = null;
            cropper_thumb.Jcrop(options, function() {
              thumb_jcrop = this;
              return bounds = thumb_jcrop.getBounds();
            });
            showPreview(selected_thumb);
            return this.thumb_jcrop = thumb_jcrop;
          }).bind(this), 20);
        });
        cropper_full.on('load', function() {
          return setTimeout((function() {
            var full_jcrop, full_selection, new_full_imageHeight, new_full_imageWidth, new_imageWidth, options;
            imageWidth_full = cropper_full.get(0).naturalWidth;
            imageHeight_full = cropper_full.get(0).naturalHeight;
            new_full_imageWidth = imageWidth_full;
            new_full_imageHeight = imageHeight_full;
            if (imageHeight_full > max_height) {
              new_full_imageWidth = imageWidth_full * (max_height / imageHeight_full);
              new_full_imageHeight = max_height;
            }
            if (new_full_imageWidth > max_width) {
              new_full_imageHeight = new_full_imageHeight * (max_width / new_full_imageWidth);
              new_imageWidth = max_width;
            }
            cropper_full.height(new_full_imageHeight);
            cropper_full.width(new_full_imageWidth);
            full_selection = scope.model.images[scope.active_image_index].image.full_selection;
            if (full_selection) {
              selected_full = JSON.parse(full_selection);
            } else {
              selected_full = {
                x: 0,
                y: 0,
                w: imageWidth_full,
                h: imageHeight_full,
                x2: imageWidth_full,
                y2: imageHeight_full,
                mode: 'full'
              };
            }
            options = {
              boxWidth: cropper_full.width(),
              boxHeight: cropper_full.height(),
              setSelect: getSelection(selected_full),
              trueSize: [imageWidth_full, imageHeight_full],
              onChange: update_selection,
              onSelect: update_selection
            };
            if (this.full_jcrop) {
              this.full_jcrop.destroy();
            }
            full_jcrop = null;
            cropper_full.Jcrop(options, function() {
              return full_jcrop = this;
            });
            return this.full_jcrop = full_jcrop;
          }).bind(this), 20);
        });
        scope.$watch('model.images', function(newValue, oldValue) {
          var image, _i, _len;
          if (newValue != null) {
            scope.story_tab = 'thumb';
            if (newValue.length > 0) {
              for (_i = 0, _len = newValue.length; _i < _len; _i++) {
                image = newValue[_i];
                image.image.active = false;
              }
              newValue[0].active = true;
              left.css({
                'opacity': 0
              });
              return scope.active_image_index = 0;
            }
          }
        });
        scope.$watch('active_image_index', function(newValue, oldValue) {
          return scope.check_active_image();
        });
        return true;
      }
    };
  }).directive('sortable', function($http, errorProcessing, imageMappingHelpers, $i18next) {
    return {
      restrict: 'A',
      scope: {
        images: "=sortable",
        lang: "=lang"
      },
      link: function(scope, element, attrs) {
        var backend;
        element = $(element);
        backend = scope.$parent.backend_url || scope.$parent.$parent.backend_url;
        element.disableSelection();
        console.log(scope.lang);
        return element.sortable({
          placeholder: "ui-state-highlight",
          tolerance: 'pointer',
          helper: 'clone',
          cancel: ".timestamp, .upload_item",
          items: "li:not(.timestamp):not(.upload_item)",
          scroll: false,
          delay: 100,
          start: function(event, ui) {
            ui.item.data('start', ui.item.index());
            ui.helper.addClass('dragged');
            return element.parents('.description').find('.timline_container').addClass('highlite');
          },
          stop: function(event, ui) {
            var elements, end, image, index, orders, start, _i, _len, _ref;
            elements = element.find('li');
            start = ui.item.data('start');
            end = ui.item.index();
            scope.images.splice(end, 0, scope.images.splice(start, 1)[0]);
            element.parents('.description').find('.timline_container').removeClass('highlite');
            if (scope.images[end].image.order !== end) {
              orders = {};
              _ref = scope.images;
              for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
                image = _ref[index];
                image.image.order = index;
                orders[image.image._id] = index;
              }
              imageMappingHelpers.update_images(scope.images[0].image.parent, orders, backend);
              return scope.$apply();
            }
          }
        });
      }
    };
  }).directive('jsDraggable', function($rootScope, $i18next, imageMappingHelpers) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var weight_calc;
        element = $(element);
        weight_calc = imageMappingHelpers.weight_calc;
        return element.draggable({
          axis: "x",
          containment: "parent",
          cursor: "pointer",
          start: function(event, ui) {
            var image;
            image = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')];
            return image.dragging = true;
          },
          drag: function(event, ui) {
            var current_time, image;
            current_time = imageMappingHelpers.calc_timestamp(ui, false);
            image = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')];
            if (image != null) {
              if (image.mappings[$rootScope.lang].timestamp !== current_time) {
                image.mappings[$rootScope.lang].timestamp = current_time;
              }
            }
            return true;
          },
          stop: function(event, ui) {
            var current_time, image, index, item, orders, _i, _len, _ref;
            console.log('drag_stop');
            current_time = imageMappingHelpers.calc_timestamp(ui, false);
            image = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')];
            image.dragging = false;
            scope.$parent.set_hover(image, false);
            if (image != null) {
              if (image.mappings[$rootScope.lang].timestamp !== current_time) {
                image.mappings[$rootScope.lang].timestamp = current_time;
              }
            }
            scope.$parent.container.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func);
            orders = {};
            _ref = scope.$parent.container.images;
            for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
              item = _ref[index];
              item.image.order = index;
              orders[item.image._id] = index;
              if (item.image._id === image.image._id) {
                imageMappingHelpers.update_image(item, scope.$parent.$parent.backend_url);
              }
            }
            imageMappingHelpers.update_images(image.image.parent, orders, scope.$parent.$parent.backend_url);
            scope.$parent.$parent.$digest();
            return event.stopPropagation();
          }
        });
      }
    };
  }).directive('droppable', function($http, errorProcessing, $i18next, imageMappingHelpers) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        element = $(element);
        element.droppable({
          accept: '.dragable_image',
          out: function(event, ui) {
            return element.removeClass('can_drop');
          },
          over: function(event, ui) {
            return element.addClass('can_drop');
          },
          drop: function(event, ui) {
            var dropped, droppedOn, found, index, item, jp_durat, jp_play, mapped_images, orders, seek_bar, target_image, target_storyset, _i, _len, _ref;
            target_storyset = element.hasClass('active_exhibit') ? scope.active_exhibit : element.hasClass('current_museum') ? scope.current_museum : void 0;
            element.removeClass('can_drop');
            found = false;
            dropped = ui.draggable;
            droppedOn = $(this);
            dropped.attr('style', '');
            seek_bar = element.find('.jp-seek-bar');
            jp_durat = element.find('.jp-duration');
            jp_play = element.find('.jp-play');
            target_image = target_storyset.images[dropped.data('array-index')];
            mapped_images = target_storyset.stories[scope.current_museum.language].mapped_images;
            if (mapped_images == null) {
              mapped_images = [];
            }
            mapped_images.push(target_image);
            target_image.mappings[dropped.data('lang')] = {};
            target_image.mappings[dropped.data('lang')].timestamp = imageMappingHelpers.calc_timestamp(ui, true);
            target_image.mappings[dropped.data('lang')].language = dropped.data('lang');
            target_image.mappings[dropped.data('lang')].media = target_image.image._id;
            target_storyset.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func);
            orders = {};
            _ref = target_storyset.images;
            for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
              item = _ref[index];
              item.image.order = index;
              orders[item.image._id] = index;
            }
            imageMappingHelpers.update_images(target_image.image.parent, orders, scope.backend_url);
            imageMappingHelpers.create_mapping(target_image, scope.backend_url);
            scope.$digest();
            return scope.recalculate_marker_positions(target_storyset.stories[scope.current_museum.language], element);
          }
        });
        return true;
      }
    };
  }).directive('sortableNested', function($http, errorProcessing, backendWrapper, $i18next) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        element = $(element);
        return element.nestedSortable({
          handle: 'div.opener',
          items: 'li.exhibit',
          listType: 'ul',
          toleranceElement: '> div.opener'
        });
      }
    };
  }).directive('exhibitsSortable', function($http, errorProcessing, backendWrapper, $i18next) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var after_index, backend, collection, element_height, element_width, elements_space, exhibit, exhibit_name, find_by_id, first_margin, get_closest_element, index, items, multiply_mode, new_number, start_index;
        element = $(element);
        backend = scope.backend_url;
        element.disableSelection();
        index = 0;
        exhibit_name = "";
        elements_space = 0;
        element_width = 0;
        element_height = 0;
        first_margin = 0;
        exhibit = {};
        multiply_mode = false;
        new_number = '';
        after_index = 0;
        start_index = 0;
        items = [];
        collection = (function() {
          switch (attrs['collection']) {
            case 'common':
              return scope.exhibits;
            case 'published':
              if (scope.grouped_exhibits != null) {
                return scope.grouped_exhibits.published;
              } else {
                return [];
              }
              break;
            case 'private':
              if (scope.grouped_exhibits != null) {
                return scope.grouped_exhibits["private"];
              } else {
                return [];
              }
              break;
            case 'invisible':
              if (scope.grouped_exhibits != null) {
                return scope.grouped_exhibits.invisible;
              } else {
                return [];
              }
              break;
            case 'draft':
              if (scope.grouped_exhibits != null) {
                return scope.grouped_exhibits.draft;
              } else {
                return [];
              }
          }
        })();
        get_closest_element = function(elements, x, y) {
          var compare_x_to, el, position, _i, _len;
          for (index = _i = 0, _len = elements.length; _i < _len; index = ++_i) {
            el = elements[index];
            el = $(el);
            position = el.offset();
            compare_x_to = first_margin + element_width + position.left;
            if (x - compare_x_to < elements_space) {
              if (y >= position.top && y <= position.top + element_height + 30) {
                return el;
                break;
              }
            }
          }
          return null;
        };
        find_by_id = function(id) {
          var item, _i, _len;
          for (_i = 0, _len = collection.length; _i < _len; _i++) {
            item = collection[_i];
            if (item._id === id) {
              return item;
            }
          }
          return null;
        };
        return element.sortable({
          placeholder: "exhibits_placeholder",
          tolerance: 'intersect',
          helper: 'clone',
          appendTo: document.body,
          cursor: "move",
          cursorAt: {
            left: -10,
            top: 0
          },
          items: "> li.exhibit:not(.dummy)",
          scroll: false,
          delay: 100,
          start: function(event, ui) {
            var margin;
            index = ui.item.data('exhibit-id');
            exhibit = find_by_id(index);
            exhibit_name = exhibit.stories[scope.current_museum.language].name;
            exhibit.active = true;
            ui.item.show();
            ui.helper.html("<span class='info'>Move " + exhibit_name + "</span>").addClass('exhibits_info');
            ui.helper.addClass('dragged');
            elements_space = parseInt($(element.find('li.exhibit')[1]).css('margin-left').split('px')[0], 10);
            element_width = ui.item.width();
            element_height = ui.item.height();
            first_margin = parseInt($(element.find('li.exhibit')[0]).css('margin-left').split('px')[0], 10);
            margin = elements_space / 2;
            element.find('.exhibits_placeholder').html("<span class='helper'></span>").find('.helper').css({
              'margin-left': "" + margin + "px"
            });
            return scope.grid();
          },
          sort: function(event, ui) {
            var curr_num, i, inset_after, inset_after_exhibit, move_text, next_num, res_last_number, res_number, target, target_element, target_exhibit, target_index, _i, _ref, _ref1;
            multiply_mode = scope.selected_count > 1 ? true : false;
            target = $(event.toElement);
            target_element = target.parents('li.exhibit');
            if (target_element.length === 0) {
              move_text = multiply_mode ? "Move " + scope.selected_count + " exhibits" : "Move " + exhibit_name;
              inset_after = get_closest_element(target.find('li.exhibit'), event.pageX, event.pageY);
              if (inset_after != null) {
                after_index = inset_after.data('exhibit-id');
                inset_after_exhibit = find_by_id(after_index);
                new_number = inset_after_exhibit.number.split('.');
                new_number[new_number.length - 1] = parseInt(new_number[new_number.length - 1], 10) + 1;
              }
            } else {
              target_index = target_element.data('exhibit-id');
              target_exhibit = find_by_id(target_index);
              next_num = target_index + 1 < collection.length ? find_by_id(target_index + 1).number.split('.') : [999999999];
              curr_num = target_exhibit.number.split('.');
              if (curr_num.length <= next_num.length || next_num[0] > curr_num[0]) {
                new_number = curr_num;
                new_number.push(1);
              } else {
                for (i = _i = _ref = target_index + 1, _ref1 = collection.length - 2; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
                  next_num = find_by_id(i + 1).number;
                  curr_num = find_by_id(i).number;
                  if (next_num.length !== curr_num.length) {
                    res_number = curr_num.split('.');
                    res_last_number = res_number[res_number.length - 1];
                    res_last_number = parseInt(res_last_number, 10) + 1;
                    res_number[res_number.length - 1] = res_last_number;
                    new_number = res_number;
                  }
                }
              }
              move_text = multiply_mode ? "Move " + scope.selected_count + " exhibits" : "" + (new_number.join('.')) + " " + exhibit_name;
            }
            element.find('.exhibits_placeholder').insertAfter(inset_after);
            return ui.helper.find('.info').text(move_text);
          },
          stop: function(event, ui) {
            var current_arr, current_item, current_last_number, elements, ex_id, item, looking_for_id, next_arr, next_item, next_last_number, prev_incremented, sort_obj, _i, _j, _k, _len, _len1, _ref;
            elements = element.find('li');
            exhibit.active = false;
            ex_id = ui.item.data('exhibit-id');
            find_by_id(ex_id).number = new_number.join('.');
            looking_for_id = find_by_id(ex_id)._id;
            if (multiply_mode) {
              items = element.find('li.exhibit.selected:not(.active)');
              items.insertAfter(ui.item);
              for (index = _i = 0, _len = items.length; _i < _len; index = ++_i) {
                item = items[index];
                item = $(item);
                exhibit = find_by_id(item.data('exhibit-id'));
                new_item_number[new_number.length - 1] = parseInt(new_number[new_number.length - 1], 10) + 1 + index;
                exhibit.number = new_item_number.join('.');
              }
            }
            collection = backendWrapper.sortArray(collection);
            prev_incremented = false;
            for (index = _j = 0, _ref = collection.length - 2; 0 <= _ref ? _j <= _ref : _j >= _ref; index = 0 <= _ref ? ++_j : --_j) {
              current_item = collection[index];
              next_item = collection[index + 1];
              current_arr = current_item.number.split('.');
              next_arr = next_item.number.split('.');
              if (current_arr.length === next_arr.length) {
                next_last_number = parseInt(next_arr[next_arr.length - 1], 10);
                current_last_number = parseInt(current_arr[current_arr.length - 1], 10);
                prev_incremented = false;
                if (next_last_number !== current_last_number + 1) {
                  prev_incremented = true;
                  next_arr[next_arr.length - 1] = current_last_number + 1;
                  next_item.number = next_arr.join('.');
                }
              } else if (next_arr.length > current_arr.length) {
                if (prev_incremented === true) {
                  if (next_arr[next_arr.length - 2] !== current_arr[current_arr.length - 1]) {
                    console.log('item was incremented and next item is child of');
                  }
                }
                if (next_arr[next_arr.length - 1] !== 1) {
                  next_arr[next_arr.length - 1] = 1;
                }
                next_item.number = next_arr.join('.');
              } else if (next_arr.length < current_arr.length) {
                next_last_number = parseInt(next_arr[next_arr.length - 1], 10);
                current_last_number = parseInt(current_arr[current_arr.length - 2], 10);
                prev_incremented = false;
                if (next_arr[next_arr.length - 1] !== current_last_number + 1) {
                  prev_incremented = true;
                  next_arr[next_arr.length - 1] = current_last_number + 1;
                  next_item.number = next_arr.join('.');
                }
              }
            }
            scope.$digest();
            scope.grid();
            setTimeout(function() {
              return element.sortable().refresh();
            }, 100);
            sort_obj = {};
            for (_k = 0, _len1 = collection.length; _k < _len1; _k++) {
              exhibit = collection[_k];
              sort_obj[exhibit._id] = exhibit.number;
            }
            return $http.post("" + scope.backend_url + "/story_set/update_numbers/" + scope.current_museum._id, sort_obj).success(function(data) {
              console.log(data);
              setTimeout(function() {
                return element.sortable("enable");
              }, 100);
              return true;
            }).error(function() {
              return errorProcessing.addError($i18next('Failed to save sort status'));
            });
          }
        });
      }
    };
  }).directive('switchToggle', function($timeout, $i18next) {
    return {
      restrict: 'A',
      controller: function($scope, $rootScope, $element, $attrs, $http) {
        var selector;
        selector = $attrs['quizSwitch'];
        $scope.quiz_state = function(form, item) {
          $scope.mark_quiz_validity(form.$valid);
          if (form.$valid) {
            $timeout(function() {
              $http.put("" + $scope.backend_url + "/quiz/" + item._id, item).success(function(data) {
                return console.log(data);
              }).error(function() {
                return errorProcessing.addError($i18next('Failed to save quiz state'));
              });
              return true;
            }, 0);
          } else {
            setTimeout(function() {
              return $("#" + selector + "_disabled").click();
            }, 300);
          }
          return true;
        };
        return $scope.mark_quiz_validity = function(valid) {
          var form, question;
          form = $("#" + selector + " form");
          if (valid) {
            form.removeClass('has_error');
          } else {
            form.addClass('has_error');
            question = form.find('#story_quiz_attributes_question, #museum_story_quiz_attributes_question');
            if (question.val() === '') {
              question.addClass('ng-invalid');
            }
          }
          return true;
        };
      },
      link: function(scope, element, attrs) {
        var selector;
        selector = attrs['quizSwitch'];
        return $("#" + selector + "_enabled, #" + selector + "_disabled").change(function() {
          var elem;
          elem = $(this);
          if (elem.attr('id') === ("" + selector + "_enabled")) {
            $("label[for=" + selector + "_enabled]").text($i18next('Enabled'));
            $("label[for=" + selector + "_disabled]").text($i18next('Disable'));
            return true;
          } else {
            $("label[for=" + selector + "_disabled]").text($i18next('Disabled'));
            $("label[for=" + selector + "_enabled]").text($i18next('Enable'));
            return true;
          }
        });
      }
    };
  }).directive('errorNotification', function(errorProcessing) {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      template: "<div class=\"error_notifications\" ng-hide=\"errors.length == 0\">\n  <div class=\"alert alert-danger\" ng-repeat=\"error in errors\">\n    {{error.error}}\n    <a class=\"close\" href=\"#\" ng-click=\"dismiss_error($index)\" >&times;</a>\n  </div>\n</div>",
      link: function(scope, element, attrs) {
        scope.errors = errorProcessing.getErrors();
        scope.dismiss_error = function(index) {
          return errorProcessing.deleteError(index);
        };
        return scope.$on('new_error', function(event, errors) {
          return scope.errors = errors;
        });
      }
    };
  }).directive('toTop', function(errorProcessing) {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      template: "<div class=\"to_top\">\n  <div class=\"to_top_panel\">\n    <div class=\"to_top_button\" title=\"Наверх\">\n      <span class=\"arrow\"><i class=\"icon-long-arrow-up\"></i></span>\n    </div>\n  </div>\n</div>",
      link: function(scope, element, attrs) {
        element = $(element);
        return element.click(function() {
          var pos;
          if (element.hasClass('has_position')) {
            element.removeClass('has_position');
            pos = element.data('scrollPosition');
            element.find('.arrow i').removeClass("icon-long-arrow-down").addClass("icon-long-arrow-up");
            return $.scrollTo(pos, 0);
          } else {
            element.addClass('has_position');
            pos = $(document).scrollTop();
            element.data('scrollPosition', pos);
            element.find('.arrow i').addClass("icon-long-arrow-down").removeClass("icon-long-arrow-up");
            return $.scrollTo(0, 0);
          }
        });
      }
    };
  }).directive("langList", function($timeout) {
    return {
      restrict: "E",
      replace: true,
      transclude: true,
      template: "<ul class=\"nav nav-tabs lang_list\">\n  <li class=\"active\">\n    <a href=\"#\" class=\"dropdown-toggle\">\n      {{current_museum.language | i18next}}\n      <i class=\"icon-chevron-down\"></i>\n    </a>\n    <ul class=\"dropdown-menu\">\n      <li ng-repeat=\"story in lang_arr\">\n        <a href=\"#\" ng-click=\"current_museum.language = story.language\">{{ story.language | i18next}}</a>\n      </li>\n      <li class=\"divider\" ng-hide=\"lang_arr.length == 0\"></li>\n      <li>\n        <a href=\"#\" ng-click=\"new_museum_language()\"> {{ 'newLanguage' | i18next }} </a>\n      </li>\n    </ul>        \n  </li>\n</ul>",
      link: function(scope, element, attrs) {
        var lang_sort, weight_calc;
        weight_calc = function(item) {
          var weight;
          weight = 0;
          if (item.language === scope.current_museum.language) {
            weight -= 100;
          }
          return weight;
        };
        lang_sort = function(a, b) {
          if (weight_calc(a) > weight_calc(b)) {
            return 1;
          } else if (weight_calc(a) < weight_calc(b)) {
            return -1;
          } else {
            return 0;
          }
        };
        return scope.$watch('current_museum.language', function(newValue, oldValue) {
          var key, value, _ref;
          scope.lang_arr = [];
          _ref = scope.current_museum.stories;
          for (key in _ref) {
            value = _ref[key];
            scope.lang_arr.push(value);
          }
          scope.lang_arr.sort(lang_sort);
          return scope.lang_arr.splice(0, 1);
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=directives.js.map
*/