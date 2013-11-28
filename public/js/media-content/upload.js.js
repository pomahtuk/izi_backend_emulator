(function() {
  var acceptableExtensions, fileSizeMb;

  fileSizeMb = 50;

  acceptableExtensions = {
    "audio": ["mp3", "ogg", "aac", "wav", "amr", "3ga", "m4a", "wma", "mp4", "mp2", "flac"],
    "image": ["jpg", "jpeg", "gif", "png", "tiff", "bmp"],
    "video": ["mp4", "m4v"]
  };

  this.correctExtension = function(object) {
    var extension;
    extension = object.files[0].name.split('.').pop().toLowerCase();
    return $.inArray(extension, acceptableExtensions[object.fileInput.context.dataset.accept]) !== -1;
  };

  this.correctFileSize = function(object) {
    return object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024;
  };

  this.initFileUpload = function(e, object, options) {
    if (object == null) {
      object = null;
    }
    if (options == null) {
      options = {};
    }
    return (object || $('.fileupload')).each(function() {
      var $this, button, cancel, container, form, progress, upload;
      upload = null;
      $this = $(this);
      form = $this.parent('form');
      container = form.parent();
      button = form.find('a.btn.browse');
      cancel = form.find('a.btn.cancel');
      progress = options.progress || form.find('.progress');
      cancel.unbind('click');
      cancel.bind('click', function(e) {
        e.preventDefault();
        if (upload) {
          return upload.abort();
        }
      });
      return $this.fileupload({
        add: function(e, data) {
          if (correctExtension(data)) {
            if (correctFileSize(data)) {
              button.addClass('disabled');
              cancel.removeClass('hide');
              progress.removeClass('hide');
              data.form.find('.help-tooltip').remove();
              return data.submit();
            } else {
              return Message.error(t('message.errors.media_content.file_size', {
                file_size: fileSizeMb
              }));
            }
          } else {
            return Message.error(t('message.errors.media_content.file_type'));
          }
        },
        beforeSend: function(jqXHR) {
          progress.find('.bar').width('0%');
          return upload = jqXHR;
        },
        success: function(result) {
          container.replaceWith(result).hide().fadeIn(function() {
            return $('a.thumb').trigger('image:uploaded');
          });
          $('#edit_story_form').trigger('form:loaded');
          return Message.notice(t('message.media_content.uploaded'));
        },
        complete: function() {
          cancel.addClass('hide');
          progress.addClass('hide');
          return button.removeClass('disabled');
        },
        error: function(result, status, errorThrown) {
          var response, responseText;
          $this.val('');
          if (errorThrown === 'abort') {
            return Message.notice(t('message.media_content.canceled'));
          } else {
            if (result.status === 422) {
              response = jQuery.parseJSON(result.responseText);
              responseText = response.link[0];
              return Message.error(responseText);
            } else {
              return Message.error(t('message.errors.media_content.try_again'));
            }
          }
        },
        progressall: function(e, data) {
          var percentage;
          percentage = parseInt(data.loaded / data.total * 100, 10);
          return progress.find('.bar').width(percentage + '%');
        }
      });
    });
  };

  this.checkAudioFiles = function() {
    return $('#audio_form[data-audio-check-url]').each(function() {
      var $this, url;
      $this = $(this);
      url = $this.data('audio-check-url');
      return $.ajax({
        url: url,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
          return $.each(response, function(key, item) {
            var audio, audioElement, btn, canPlay;
            btn = $('.btn.' + key);
            if (item.exist) {
              audio = $this.find('.audio-upload-form').find('audio.' + key);
              audio.empty();
              $('<source>').attr('src', item.file).appendTo(audio);
              audioElement = audio.get(0);
              if (audioElement) {
                audioElement.pause();
                audioElement.load();
                canPlay = !!audioElement.canPlayType && audioElement.canPlayType(item.content_type) !== '';
                console.log(canPlay + ' - ' + item.content_type);
              }
              $('.play.' + key).find('i').removeClass('icon-pause').addClass('icon-play');
              if (canPlay) {
                return btn.removeClass('disabled hide');
              } else {
                return btn.addClass('disabled').removeClass('hide');
              }
            } else {
              return btn.addClass('disabled');
            }
          });
        },
        error: function() {
          return Message.notice(t('message.media_content.not_processed_yet'));
        }
      });
    });
  };

  $(function() {
    $(document).on('click', 'form a.browse', function() {
      var $this, form;
      $this = $(this);
      form = $this.parents('form');
      if (!$this.hasClass('disabled')) {
        return form.find(':file').trigger('click');
      }
    });
    return initFileUpload();
  });

}).call(this);
