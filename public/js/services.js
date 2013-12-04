(function() {
  "use strict";
  angular.module("Museum.services", []).service("sharedProperties", function($rootScope) {
    var property;
    property = {};
    return {
      getProperty: function(name) {
        return property[name];
      },
      setProperty: function(name, value) {
        property[name] = value;
        return $rootScope.$broadcast("exhibitChange");
      }
    };
  }).service("storySetValidation", function($rootScope, $timeout) {
    return {
      checkValidity: function(scope) {
        if (scope.item.images == null) {
          scope.item.images = [];
        }
        if (scope.item.long_description == null) {
          scope.item.long_description = '';
        }
        if (scope.item.long_description.length !== 0 && scope.item.audio && (scope.root.number != null) && scope.root.images.length >= 1) {
          this.markValid(scope);
          return $rootScope.$broadcast('changes_to_save', scope);
        } else {
          return this.markInvalid(scope);
        }
      },
      markInvalid: function(scope) {
        console.log('invalid');
        if (scope.item.status === 'published') {
          scope.root.invalid = true;
          return $timeout(function() {
            scope.item.status = 'passcode';
            if (scope.$digest != null) {
              scope.$digest();
            }
            return $rootScope.$broadcast('changes_to_save', scope);
          }, 100);
        } else {
          return $rootScope.$broadcast('changes_to_save', scope);
        }
      },
      markValid: function(scope) {
        console.log('valid');
        return scope.root.invalid = false;
      }
    };
  }).service("imageMappingHelpers", function($rootScope, errorProcessing, $http, $i18next) {
    var weight_calc;
    weight_calc = function(item) {
      var weight;
      weight = 0;
      weight += item.image.order;
      if (item.mappings[$rootScope.lang] != null) {
        weight -= 100;
      }
      return weight;
    };
    return {
      sort_weight_func: function(a, b) {
        if (weight_calc(a) > weight_calc(b)) {
          return 1;
        } else if (weight_calc(a) < weight_calc(b)) {
          return -1;
        } else {
          return 0;
        }
      },
      sort_time_func: function(a, b) {
        if ((a.mappings[$rootScope.lang] != null) && (b.mappings[$rootScope.lang] != null)) {
          if (a.mappings[$rootScope.lang].timestamp >= 0) {
            if (a.mappings[$rootScope.lang].timestamp > b.mappings[$rootScope.lang].timestamp) {
              return 1;
            } else if (a.mappings[$rootScope.lang].timestamp < b.mappings[$rootScope.lang].timestamp) {
              return -1;
            }
          }
        }
        return 0;
      },
      calc_timestamp: function(ui, initial) {
        var container_width, current_position, current_time, duration, jp_durat, jp_play, pixel_sec_weight, seek_bar, total_seconds;
        if (initial == null) {
          initial = false;
        }
        seek_bar = $('.jp-seek-bar:visible');
        jp_durat = $('.jp-duration:visible');
        jp_play = $('.jp-play:visible');
        if (initial) {
          current_position = ui.offset.left - seek_bar.offset().left;
        } else {
          current_position = ui.position.left - jp_play.width();
        }
        container_width = seek_bar.width() - 15;
        duration = jp_durat.text();
        total_seconds = parseInt(duration.split(':')[1], 10) + parseInt(duration.split(':')[0], 10) * 60;
        pixel_sec_weight = total_seconds / container_width;
        current_time = Math.round(current_position * pixel_sec_weight);
        if (current_time <= 0) {
          current_time = 0;
        }
        return current_time;
      },
      update_image: function(image, backend_url) {
        $http.put("" + backend_url + "/media/" + image.image._id, image.image).success(function(data) {
          var mapping;
          console.log('ok');
          if (image.mappings[$rootScope.lang] != null) {
            mapping = image.mappings[$rootScope.lang];
            if (mapping._id != null) {
              return $http.put("" + backend_url + "/media_mapping/" + mapping._id, mapping).success(function(data) {
                return console.log('ok');
              }).error(function() {
                return errorProcessing.addError($i18next('Failed to set timestamp'));
              });
            }
          }
        }).error(function() {
          return errorProcessing.addError($i18next('Failed to set timestamp'));
        });
        return true;
      },
      update_images: function(parent, orders, backend_url) {
        $http.post("" + backend_url + "/media_for/" + parent + "/reorder", orders).success(function(data) {
          return console.log('ok');
        }).error(function() {
          return errorProcessing.addError($i18next('Failed to update order'));
        });
        return true;
      },
      create_mapping: function(image, backend_url) {
        $http.post("" + backend_url + "/media_mapping/", image.mappings[$rootScope.lang]).success(function(data) {
          return image.mappings[$rootScope.lang] = data;
        }).error(function() {
          return errorProcessing.addError($i18next('Failed to set timestamp'));
        });
        return true;
      }
    };
  }).service("uploadHelpers", function() {
    return {
      cavas_processor: function(img, type) {
        var canvas;
        if (type == null) {
          type = "image/jpeg";
        }
        console.log('called');
        canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;
        if (canvas.getContext && canvas.toBlob) {
          canvas.getContext("2d").drawImage(img, 0, 0, img.width, img.height);
          canvas.toBlob((function(blob) {
            var fileupload;
            fileupload = $('#drop_down, #museum_drop_down').filter(':visible').find("input[type=file]");
            return fileupload.fileupload("add", {
              files: [blob]
            });
          }), type);
        }
        return true;
      }
    };
  }).service("errorProcessing", function($rootScope, $timeout) {
    return {
      errors: [],
      addError: function(error) {
        var error_object;
        error_object = {
          error: error
        };
        this.errors.push(error_object);
        return $rootScope.$broadcast('new_error', this.errors);
      },
      getErrors: function() {
        return this.errors;
      },
      clearErrors: function() {
        this.errors = [];
        return $rootScope.$broadcast('new_error', this.errors);
      },
      deleteError: function(index) {
        this.errors.splice(index, 1);
        return $rootScope.$broadcast('new_error', this.errors);
      }
    };
  }).service("backendWrapper", function($http, ngProgress, $location, $i18next) {
    return {
      museum_id: "529ee18e13b106fb0f000002",
      content_provider_id: "529ee18e13b106fb0f000001",
      backend_url: "http://192.168.158.128:3000/api",
      museums: [],
      exhibits: [],
      modal_translations: [],
      langs: [],
      current_museum: {},
      active_exhibit: {},
      sort_field: 'number',
      sort_direction: 1,
      ajax_progress: true,
      grouped_positions: {},
      hier_exhibits: {},
      sortArray: function(collection, sort_field, sort_direction) {
        var index, item, n, positive, sumbol, sumbol_index, temp_collection, temp_item, _i, _j, _k, _len, _len1, _len2, _ref;
        if (sort_field == null) {
          sort_field = sort_field;
        }
        if (sort_direction == null) {
          sort_direction = sort_direction;
        }
        temp_collection = [];
        n = void 0;
        positive = sort_direction === 1 ? 1 : -1;
        for (index = _i = 0, _len = collection.length; _i < _len; index = ++_i) {
          item = collection[index];
          temp_collection[index] = item;
          if (item.number != null) {
            temp_collection[index].number = item.number.toString().match(/([^0-9]+)|([0-9]+)/g);
          } else {
            temp_collection[index].number = [''];
          }
          _ref = temp_collection[index].number;
          for (sumbol_index = _j = 0, _len1 = _ref.length; _j < _len1; sumbol_index = ++_j) {
            sumbol = _ref[sumbol_index];
            if (!isNaN(n = parseInt(temp_collection[index].number[sumbol_index]))) {
              temp_collection[index].number[sumbol_index] = n;
            }
          }
        }
        temp_collection.sort(function(x, y) {
          var i, _k, _len2, _ref1;
          _ref1 = x.number;
          for (i = _k = 0, _len2 = _ref1.length; _k < _len2; i = ++_k) {
            sumbol = _ref1[i];
            if (x.number[i] < y.number[i]) {
              return 0 + positive;
            }
            if (x.number[i] > y.number[i] || y.number.length < i) {
              return 0 - positive;
            }
          }
          return 0;
        });
        for (_k = 0, _len2 = temp_collection.length; _k < _len2; _k++) {
          temp_item = temp_collection[_k];
          temp_item.number = temp_item.number.join("");
        }
        return temp_collection;
      },
      recurse_enter_hierarchy: function(hierarchy, index_arr, new_val) {
        var index;
        index = parseInt(index_arr[0], 10);
        if (hierarchy[index] == null) {
          hierarchy[index] = {};
        }
        if (index_arr.length === 1) {
          return hierarchy[index] = {
            0: new_val
          };
        } else {
          index_arr.splice(0, 1);
          return this.recurse_enter_hierarchy(hierarchy[index], index_arr, new_val);
        }
      },
      form_hierarchial_object: function(collection) {
        var hierarchy_data, item, new_object, _i, _len;
        new_object = {};
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          item = collection[_i];
          hierarchy_data = item.number.split('.');
          this.recurse_enter_hierarchy(new_object, hierarchy_data, item);
        }
        return new_object;
      },
      reload_exhibits: function(sort_field, sort_direction, q) {
        var request;
        if (sort_field == null) {
          sort_field = sort_field;
        }
        if (sort_direction == null) {
          sort_direction = sort_direction;
        }
        request = $http.get("" + this.backend_url + "/provider/" + this.content_provider_id + "/museums/" + this.museum_id + "/exhibits/" + this.sort_field + "/" + this.sort_direction);
        request.success((function(data) {
          var exhibit, image, item, new_exhibits, story, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2;
          new_exhibits = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            if (item != null) {
              exhibit = item.exhibit;
              exhibit.images = [];
              exhibit.mapped_images = [];
              exhibit.cover = {};
              _ref = item.images;
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                image = _ref[_j];
                exhibit.images.push(image);
                if (image.image.cover === true) {
                  exhibit.cover = image.image;
                }
              }
              exhibit.stories = {};
              _ref1 = item.stories;
              for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                story = _ref1[_k];
                story.story.quiz = story.quiz.quiz;
                story.story.audio = story.audio;
                story.story.video = story.video;
                story.story.quiz.answers = story.quiz.answers;
                story.story.mapped_images = [];
                _ref2 = exhibit.images;
                for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
                  image = _ref2[_l];
                  if (image.mappings[story.story.language]) {
                    story.story.mapped_images.push(image);
                  }
                }
                exhibit.stories[story.story.language] = story.story;
              }
              new_exhibits.push(exhibit);
            }
          }
          console.log('anim completed');
          new_exhibits = this.sortArray(new_exhibits);
          this.active_exhibit = new_exhibits[0];
          this.exhibits = new_exhibits;
          this.ajax_progress = false;
          if (new_exhibits.length === 0) {
            this.active_exhibit = {
              index: 0,
              name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
              number: '1',
              image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
              thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
              publish_state: 'all',
              description: '',
              qr_code: {
                url: '/img/qr_code.png',
                print_link: 'http://localhost:8000/img/qr_code.png'
              },
              images: [
                {
                  image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                  thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                  id: 1,
                  edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
                }, {
                  image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg',
                  thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg',
                  id: 2,
                  edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
                }
              ],
              stories: {
                ru: {
                  name: 'Богоматерь Владимирская, с двунадесятыми праздниками',
                  description: 'test description',
                  publish_state: 'all',
                  audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg',
                  quiz: {
                    question: 'are you sure?',
                    description: 'can you tell me?',
                    state: 'published',
                    answers: [
                      {
                        title: 'yes',
                        correct: false,
                        id: 0
                      }, {
                        title: 'may be',
                        correct: true,
                        id: 1
                      }, {
                        title: 'who cares?',
                        correct: false,
                        id: 2
                      }, {
                        title: 'nope',
                        correct: false,
                        id: 3
                      }
                    ]
                  }
                }
              }
            };
          }
          if (q != null) {
            return q.resolve();
          }
        }).bind(this));
        return request.error(function() {
          if (q != null) {
            return q.reject();
          }
        });
      },
      fetch_data: function(museum_id, q) {
        var request;
        ngProgress.color('#fd6e3b');
        ngProgress.start();
        console.log('anim started', museum_id);
        if (museum_id != null) {
          this.museum_id = museum_id;
        }
        request = $http.get("" + this.backend_url + "/provider/" + this.content_provider_id + "/museums");
        request.success((function(data) {
          var found, image, item, lang, museum, story, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3;
          this.museums = [];
          found = false;
          this.langs = [];
          this.modal_translations = {};
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            museum = item.exhibit;
            museum.def_lang = "ru";
            if (museum.language == null) {
              museum.language = "ru";
            }
            museum.package_status = "process";
            museum.stories = {};
            museum.images = [];
            museum.mapped_images = [];
            museum.cover = {};
            _ref = item.images;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              image = _ref[_j];
              museum.images.push(image);
              if (image.image.cover === true) {
                museum.cover = image.image;
              }
            }
            _ref1 = item.stories;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              story = _ref1[_k];
              story.story.city = "Saint-Petersburg";
              story.story.quiz = story.quiz.quiz;
              story.story.audio = story.audio;
              story.story.video = story.video;
              story.story.quiz.answers = story.quiz.answers;
              story.story.mapped_images = [];
              _ref2 = museum.images;
              for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
                image = _ref2[_l];
                if (image.mappings[story.story.language]) {
                  story.story.mapped_images.push(image);
                }
              }
              museum.stories[story.story.language] = story.story;
              this.langs.push(story.story.language);
            }
            this.museums.push(museum);
            museum.active = false;
            if (museum._id === this.museum_id) {
              museum.active = true;
              this.current_museum = museum;
              found = true;
            }
            this.langs.unique();
          }
          this.museums = this.sortArray(this.museums);
          if (!found) {
            this.current_museum = this.museums[0];
            this.current_museum.def_lang = "ru";
            if (museum.language == null) {
              this.current_museum.language = "ru";
            }
            this.museum_id = this.current_museum._id;
          }
          _ref3 = this.langs;
          for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
            lang = _ref3[_m];
            this.modal_translations[lang] = {
              name: $i18next(lang)
            };
          }
          return this.reload_exhibits(null, null, q);
        }).bind(this));
        return request.error(function() {
          if (q != null) {
            return q.reject();
          }
        });
      }
    };
  });

}).call(this);
