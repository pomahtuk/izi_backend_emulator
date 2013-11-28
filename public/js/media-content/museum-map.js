(function() {
  String.prototype.truncate = function(n) {
    var dots;
    if (this.length > n) {
      dots = '…';
    }
    return this.substr(0, n - 1) + (dots || '');
  };

  $(function() {
    var MuseumMap;
    MuseumMap = (function() {
      function MuseumMap(element, modal, planInput) {
        var _this = this;
        this.element = element;
        this.modal = modal;
        this.planInput = planInput;
        this.container = this.element.parents('li');
        this.image = this.element.find('img');
        this.progress = this.container.find('.progress');
        this.planName = this.element.data('title');
        this.planInput.val(this.planName);
        this.modalBody = this.modal.find('.modal-body');
        this.modalImage = this.modalBody.find('img');
        this.modalContainer = this.modalBody.find('.modal-container');
        this.file = this.modal.find(':file').get(0);
        this.modalContainer.addClass('hidden');
        this.modalImage.attr('src', this.image.attr('src'));
        this.modalBody.css({
          'min-height': '200px'
        }).addClass('ajax-loader');
        this.showModal();
        this.modalImage.on('load', function() {
          _this.modalContainer.removeClass('hidden');
          _this.modalBody.css({
            'min-height': '0'
          }).removeClass('ajax-loader');
          if (_this.initCallback) {
            return _this.initCallback.call(_this);
          }
        });
      }

      MuseumMap.prototype.showModal = function() {
        return this.modal.modal('show');
      };

      MuseumMap.prototype.hideModal = function() {
        this.modal.modal('hide');
        return this.clearImage();
      };

      MuseumMap.prototype.clearImage = function() {
        return this.modalImage.attr('src', '');
      };

      MuseumMap.prototype.save = function(saveCallback) {
        var data, progressSave,
          _this = this;
        this.saveCallback = saveCallback;
        this.progress.show().find('.bar').width('0%');
        progressSave = function(evt) {
          var percentComplete;
          if (evt.lengthComputable) {
            percentComplete = (evt.loaded / evt.total) * 100;
            return _this.progress.find('.bar').width("" + percentComplete + "%");
          }
        };
        data = new FormData;
        data.append('map[title]', this.planInput.val());
        if (this.file.files[0]) {
          data.append('map[link]', this.file.files[0]);
        }
        return $.ajax({
          url: this.element.attr('href'),
          xhr: function() {
            var xhr;
            xhr = new XMLHttpRequest();
            xhr.upload.addEventListener('progress', progressSave, false);
            return xhr;
          },
          type: 'PUT',
          data: data,
          cache: false,
          contentType: false,
          processData: false,
          success: function(response) {
            return _this.update.call(_this, response);
          },
          error: function(response) {
            return _this.error.call(_this, response);
          },
          complete: function() {
            if (_this.saveCallback) {
              _this.saveCallback.call(_this);
            }
            return _this.progress.hide();
          }
        });
      };

      MuseumMap.prototype.update = function(response) {
        return this.container.replaceWith(response);
      };

      MuseumMap.prototype.error = function(response) {
        var err, errors, _i, _len, _ref, _results;
        if (response.status === 422) {
          errors = jQuery.parseJSON(response.responseText);
          if (errors.link) {
            _ref = errors.link;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              err = _ref[_i];
              _results.push(Message.error(err));
            }
            return _results;
          }
        }
      };

      return MuseumMap;

    })();
    return $('#maps').on('click', 'li form a.thumbnail', function(e) {
      var fileField, modal, museumMap, planName, saveBtn, updateBtn;
      e.preventDefault();
      modal = $('#map_modal');
      saveBtn = modal.find('.save-map');
      updateBtn = modal.find('.change-map');
      planName = modal.find('#plan_name');
      fileField = modal.find('#new_file');
      museumMap = new MuseumMap($(this), modal, planName);
      saveBtn.unbind('click').on('click', function() {
        museumMap.hideModal();
        return museumMap.save();
      });
      modal.on('hidden', function() {
        return museumMap.clearImage();
      });
      fileField.val('');
      updateBtn.attr('title', '');
      updateBtn.text(updateBtn.data('default'));
      updateBtn.unbind('click').on('click', function() {
        var $this;
        $this = $(this);
        return fileField.trigger('click');
      });
      return fileField.on('change', function() {
        var name;
        if (this.files[0]) {
          name = this.files[0].name;
          updateBtn.text(name.truncate(30));
          return updateBtn.attr('title', name);
        }
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=museum-map.js.map
*/