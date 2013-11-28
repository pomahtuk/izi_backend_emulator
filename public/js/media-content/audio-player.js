(function() {
  $(function() {
    var originalAudio, playBtn, transcodedAudio;
    playBtn = '.audio-upload-form .play';
    transcodedAudio = '.audio-upload-form audio.transcoded';
    originalAudio = '.audio-upload-form audio.original';
    return $(document).on('click', playBtn, function(e) {
      var $this, audio;
      e.preventDefault();
      $this = $(this);
      if ($this.hasClass('disabled')) {
        return false;
      }
      if ($this.hasClass('original')) {
        audio = $(originalAudio).get(0);
      } else {
        audio = $(transcodedAudio).get(0);
      }
      if (audio.paused) {
        audio.play();
      } else {
        audio.pause();
      }
      $(audio).on('pause ended', function() {
        if ($this.hasClass('disabled')) {
          return false;
        }
        return $this.find('i').removeClass('icon-pause').addClass('icon-play');
      });
      return $(audio).bind('play', function() {
        if ($this.hasClass('disabled')) {
          return false;
        }
        return $this.find('i').removeClass('icon-play').addClass('icon-pause');
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=audio-player.js.map
*/