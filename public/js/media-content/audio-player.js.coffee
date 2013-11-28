$ ->
  playBtn = '.audio-upload-form .play'
  transcodedAudio = '.audio-upload-form audio.transcoded'
  originalAudio = '.audio-upload-form audio.original'

  # Play/Pouse functional
  $(document).on 'click', playBtn, (e) ->
    e.preventDefault()
    $this = $(this)
    return false if $this.hasClass('disabled')

    if $this.hasClass('original')
      audio = $(originalAudio).get(0)
    else
      audio = $(transcodedAudio).get(0)
    if audio.paused
      audio.play()
    else
      audio.pause()

    $(audio).on 'pause ended',->
      if $this.hasClass('disabled')
        return false
      $this.find('i').removeClass('icon-pause').addClass('icon-play')

    $(audio).bind 'play',->
      if $this.hasClass('disabled')
        return false
      $this.find('i').removeClass('icon-play').addClass('icon-pause')
