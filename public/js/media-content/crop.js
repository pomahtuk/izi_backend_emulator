(function() {
  this.Crop = (function() {
    function Crop(element, modal, initCallback) {
      var _this = this;
      this.element = element;
      this.modal = modal;
      this.initCallback = initCallback;
      this.image = this.element.find('img');
      this.progress = this.element.parent().find('.progress');
      this.cropImage = $('<img />', {
        "class": 'hidden',
        src: this.image.attr('data-crop-url')
      });
      this.cropData = this.image.attr('data-crop');
      this.modal.find('.image-for-crop').html(this.cropImage);
      this.modalBody = this.modal.find('.modal-body');
      this.modalBody.css({
        'min-height': '200px'
      }).addClass('ajax-loader');
      this.showModal();
      this.cropImage.on('load', function() {
        var jcrop, options;
        _this.imageWidth = _this.cropImage.get(0).naturalWidth;
        _this.imageHeight = _this.cropImage.get(0).naturalHeight;
        options = {
          boxWidth: 530,
          boxHeight: 400,
          setSelect: _this.getSelection(),
          trueSize: [_this.imageWidth, _this.imageHeight],
          aspectRatio: _this.detectRatio(),
          onChange: _this.onChange()
        };
        jcrop = null;
        _this.cropImage.removeClass('hidden');
        _this.modalBody.css({
          'min-height': '0'
        }).removeClass('ajax-loader');
        _this.cropImage.Jcrop(options, function() {
          return jcrop = this;
        });
        _this.jcrop = jcrop;
        _this.modal.unbind('hide').on('hide', function() {
          return _this.jcrop.destroy();
        });
        if (_this.initCallback) {
          return _this.initCallback.call(_this);
        }
      });
    }

    Crop.prototype.cropDataArray = function() {
      var array;
      if (!this.cropData) {
        return false;
      }
      array = this.cropData.split(/\s*,\s*/);
      if (!array.empty() && array[0]) {
        array[0] = parseInt(array[0], 10);
        array[1] = parseInt(array[1], 10);
        array[2] = array[0] + parseInt(array[2], 10);
        array[3] = array[1] + parseInt(array[3], 10);
        return array;
      } else {
        return false;
      }
    };

    Crop.prototype.getSelection = function() {
      var cropSelect;
      cropSelect = this.cropDataArray();
      if (!cropSelect && this.imageWidth && this.imageHeight) {
        cropSelect = [0, 0, this.imageWidth, this.imageHeight];
      }
      return cropSelect;
    };

    Crop.prototype.detectRatio = function(sel) {
      var goodSizesHW, goodSizesWH, sameHeight, sameWidth;
      if (sel == null) {
        sel = this.getSelection();
      }
      sameWidth = sel[2] === this.imageWidth;
      sameHeight = sel[3] === this.imageHeight;
      goodSizesHW = sameHeight && (sel[3] / sel[2] <= 3 / 4 + 1e-2);
      goodSizesWH = sameWidth && (sel[3] / sel[2] >= 3 / 4 - 1e-2);
      if ((sameWidth || sameHeight) && (goodSizesHW || goodSizesWH)) {
        return null;
      } else {
        return 4 / 3;
      }
    };

    Crop.prototype.onChange = function() {
      var previousRatio, self;
      self = this;
      previousRatio = this.detectRatio();
      return function() {
        var newRatio, sel;
        if (!(this instanceof Window)) {
          sel = this.tellSelect();
          sel = [parseInt(sel.x, 10), parseInt(sel.y, 10), parseInt(sel.w, 10), parseInt(sel.h, 10)];
          newRatio = self.detectRatio(sel);
          if (newRatio !== previousRatio) {
            previousRatio = newRatio;
            return this.setOptions({
              aspectRatio: newRatio
            });
          }
        }
      };
    };

    Crop.prototype.showModal = function() {
      return this.modal.modal('show');
    };

    Crop.prototype.hideModal = function() {
      return this.modal.modal('hide');
    };

    Crop.prototype.save = function(saveCallback) {
      var cropOptions, data,
        _this = this;
      this.saveCallback = saveCallback;
      data = new FormData;
      cropOptions = this.jcrop.tellSelect();
      this.image.attr('data-crop', [cropOptions.x, cropOptions.y, cropOptions.w, cropOptions.h].join(','));
      data.append('image[crop_x]', cropOptions.x);
      data.append('image[crop_y]', cropOptions.y);
      data.append('image[crop_w]', cropOptions.w);
      data.append('image[crop_h]', cropOptions.h);
      return $.ajax({
        url: this.element.attr('href'),
        type: 'POST',
        data: data,
        cache: false,
        contentType: false,
        processData: false,
        beforeSend: function() {
          return _this.progress.show().find('.bar').width('100%');
        },
        success: function(response) {
          return _this.update.apply(_this, [response]);
        },
        error: function(response) {
          return _this.error.apply(_this, [response]);
        },
        complete: function() {
          _this.progress.hide().find('.bar').width('0%');
          if (_this.saveCallback) {
            return _this.saveCallback.call(_this);
          }
        }
      });
    };

    Crop.prototype.update = function(response) {
      return this.image.attr('src', response.thumb + '?_=' + new Date().getTime());
    };

    Crop.prototype.error = function(response) {
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

    return Crop;

  })();

  $(function() {
    return $('#images').on('click', 'li form a.thumbnail', function(e) {
      var crop, modal, saveBtn;
      e.preventDefault();
      modal = $('#crop_modal');
      saveBtn = modal.find('.save-crop');
      crop = new Crop($(this), modal);
      return saveBtn.unbind('click').on('click', function() {
        crop.hideModal();
        return crop.save(function() {
          return $('a.thumb').trigger('image:cropped');
        });
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=crop.js.map
*/