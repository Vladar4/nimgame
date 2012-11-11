import
  os, math,
  sdl, sdl_mixer,
  common


# Sound/channels/chunks

proc setChannels*(num: int): int {.inline.} =
  ## Allocate ``num`` of channels.
  ##
  ## **Return** number of channels allocated.
  return sdlmixer.allocateChannels(cint(num))


proc setAudioVolume*(volume: int, channel: int = -1) {.inline.} =
  ## Set ``volume`` of ``channel`` (0..128).
  ##
  ## ``channel`` = -1 for all channels.
  discard sdl_mixer.volume(cint(channel), cint(volume))


proc getAudioVolume*(channel: int = -1): int {.inline.} =
  ## Get volume of ``channel`` (0..128).
  ##
  ## ``channel`` = -1 to get average volume of all channels.
  return sdl_mixer.volume(cint(channel), -1)


proc getChunk*(channel: int): PChunk =
  ## Get chunk playing on ``channel``.
  ##
  ## **Nil** is returned if the ``channel`` is not allocated,
  ## or if ``channel`` has not played any samples yet. 
  if channel < 0: return nil
  return sdl_mixer.getChunk(cint(channel))


proc free*(obj: var PChunk) {.inline.} =
  ## Free chunk.
  sdl_mixer.freeChunk(obj)
  obj = nil


proc load*(obj: var PChunk, filename: string) {.inline.} =
  ## Load sample from file to given chunk (or **nil** on errors).
  if obj != nil:
    sdl_mixer.freeChunk(obj)
    obj = nil
  obj = sdl_mixer.loadWAV(filename)


proc play*(obj: PChunk, channel: int = -1, loops: int = 0,
           timed: int = 0, fadein: int = 0) {.inline.} =
  ## Play chunk.
  ##
  ## ``loops``: number of loops.
  ##
  ## ``timed``: millisecond limit to play sample, at most.
  ##
  ## ``fadein``: milliseconds of time for fade-in effect.
  if obj != nil:
    var chn: int = -1
    if timed != 0 and fadein != 0:
      chn = sdl_mixer.fadeInChannelTimed(cint(channel), obj, cint(loops),
                                         cint(fadein), cint(timed))
    elif fadein != 0:
      chn = sdl_mixer.fadeInChannel(cint(channel), obj,
                                    cint(loops), cint(fadein))
    elif timed != 0:
      chn = sdl_mixer.playChannelTimed(cint(channel), obj,
                                       cint(loops), cint(timed))
    else:
      chn = sdl_mixer.playChannel(cint(channel), obj, cint(loops))
    if chn < 0:
      echo(sdl.getError())


proc channelFinished*(callback: TChannelFinished) {.inline.} =
  ## Set ``callback`` to call when any channel finishes playback.
  ##
  ## **Note**: NEVER call sld_mixer functions,
  ## nor sdl.lockAudio from a ``callback`` function.
  sdl_mixer.channelFinished(callback)


proc pauseChannel*(channel: int = -1) {.inline.} =
  ## Pause ``channel``.
  ##
  ## ``channel`` = -1 to pause all channels.
  sdl_mixer.pause(cint(channel))


proc resumeChannel*(channel: int = -1) {.inline.} =
  ## Resume playing of ``channel``.
  ##
  ## ``channel`` = -1 to resume playing of all channels.
  sdl_mixer.resume(cint(channel))


proc toggleChannelPause*(channel: int = -1) =
  ## Pause channel when playing or resume playing when paused.
  if sdl_mixer.paused(cint(channel)) == 0: sdl_mixer.pause(cint(channel))
  else: sdl_mixer.resume(cint(channel))


proc channelPaused*(channel: int = -1): bool =
  ## **Return** **true** if channel is paused and **false** if not.
  ##
  ## ``channel`` = -1 to check if any of channels is paused.
  if sdl_mixer.paused(cint(channel)) == 0: return false
  else: return true


proc pausedChannelsCount*(): int {.inline.} =
  ## Get number of paused channels.
  return sdl_mixer.paused(-1)


proc haltChannel*(channel: int = -1) {.inline.} =
  ## Halt channel.
  ##
  ## ``channel`` = -1 to halt all channels.
  discard sdl_mixer.haltChannel(cint(channel))


proc expireChannel*(channel, ms: int): int {.inline.} =
  ## Halt channel playback after ``ms`` milliseconds.
  ##
  ## ``channel`` = -1 to halt all channels.
  ##
  ## *Return* number of channels set to expire.
  return sdl_mixer.expireChannel(cint(channel), cint(ms))


proc fadeOutChannel*(channel, ms: int): int {.inline.} =
  ## Gradually fade out ``channel`` over ``ms`` milliseconds starting from now.
  ##
  ## ``channel`` = -1 to fade out all channels.
  ##
  ## **Return** number of channells set to fade out.
  return sdl_mixer.fadeOutChannel(cint(channel), cint(ms))


proc getChannelFading*(channel: int): TFading {.inline.} =
  ## Get fadind status from ``channel``:
  ## * ``MIX_NO_FADING``
  ## * ``MIX_FADING_OUT``
  ## * ``MIX_FADING_IN``
  ##
  ## **Note**: -1 is not valid, adn will probably crash the program.
  return sdl_mixer.fadingChannel(cint(channel))


proc channelPlaying*(channel: int = -1): bool =
  ## Check if ``channel`` playing or not.
  ##
  ## ``channel`` = -1 to check if any channel is playing.
  if sdl_mixer.playing(cint(channel)) == 0: return false
  else: return true


proc playingChannelsCount*(): int {.inline.} =
  ## Get number of playing channels.
  return sdl_mixer.playing(-1)


proc volume*(obj: PChunk): int {.inline.} =
  ## Get volume of the chunk (0..128).
  return sdl_mixer.volumeChunk(obj, -1)


proc `volume=`*(obj: PChunk, value: int) {.inline.} =
  ## Set volume of the chunk (0..128).
  if value > 0:
    discard sdl_mixer.volumeChunk(obj, cint(value))
  else:
    discard sdl_mixer.volumeChunk(obj, 0)


# Groups

proc reserveChannels*(num: int): int {.inline.} =
  ## Reserve ``num`` channels from being used when playing samples
  ## when passing in -1 as a channel number to playback functions.
  ##
  ## The channels are reserved starting from ``0`` to ``num-1``.
  ##
  ## Passing in ``0`` will unreserve all channels.
  ##
  ## Normally sdl_mixer starts without any channels reserved.
  ##
  ## **Return** number of channels reserved.
  return sdl_mixer.reserveChannels(cint(num))


proc groupChannel*(channel, tag: int): bool =
  ## Add ``channel`` to group ``tag``,
  ## or reset it's group to the default group tag (-1).
  ##
  ## **Return** **true** on success
  ## or **false** when the channel specified is invalid.
  if sdl_mixer.groupChannel(cint(channel), cint(tag)) != 1:
    echo(sdl.getError())
    return false
  return true


proc groupChannels*(fromChannel, toChannel, tag: int): int {.inline.} =
  ## Add channels starting at ``from`` up through ``to`` to group ``tag``,
  ## or reset it's group to the default group tag (-1).
  ##
  ## **Return** number of tagged channels.
  return sdl_mixer.groupChannels(cint(fromChannel), cint(toChannel), cint(tag))


proc groupCount*(tag: int): int {.inline.} =
  ## **Return** number of channels in group ``tag``.
  ##
  ## ``tag`` = -1 to count ALL channels.
  return sdl_mixer.groupCount(cint(tag))


proc groupAvailable*(tag: int): int {.inline.} =
  ## Find the first available (not playing) channel in group ``tag``.
  ##
  ## ``tag`` = -1 to search ALL channels.
  ##
  ## **Return** channel found on success,
  ## or -1 when no channels in the group are available.
  return sdl_mixer.groupAvailable(cint(tag))


proc groupOldest*(tag: int): int {.inline.} =
  ## Find the oldest actively playing channel in group ``tag``.
  ##
  ## ``tag`` = -1 to search ALL channels.
  ##
  ## **Return** channel found on success,
  ## or -1 when no channels in the group are playing or the group is empty.
  return sdl_mixer.groupOldest(cint(tag))


proc groupNewer*(tag: int): int {.inline.} =
  ## Find the newest, most recently started, actively playing channel
  ## in group ``tag``.
  ##
  ## ``tag`` = -1 to search ALL channels.
  ##
  ## **Return** channel found on success,
  ## or -1 when no channels in the group are playing or the group is empty.
  return sdl_mixer.groupNewer(cint(tag))


proc fadeOutGroup*(tag, ms: int): int {.inline.} =
  ## Gradually fade out channels in group ``tag`` over ``ms`` milliseconds
  ## starting from now.
  ##
  ## *Note*: -1 will NOT fade all channels out.
  ## Use fadeOutChannel(-1) for that instead.
  ##
  ## **Return** number of channels to fade out.
  return sdl_mixer.fadeOutGroup(cint(tag), cint(ms))


proc haltGroup*(tag: int) {.inline.} =
  ## Halt playback on all channels in group ``tag``.
  discard sdl_mixer.haltGroup(cint(tag))


# Effects

proc registerEffect(channel: int, func: TEffectFunc,
                    done: TEffectDone, arg: Pointer): bool =
  ## ``channel``: channel number to register ``func`` and ``done`` on.
  ##
  ## ``func``: function pointer for the effects processor.
  ##
  ## ``done``: function pointer for any cleanup routine to be called
  ## when the channel is done playing a sample.
  ## This may be **nil** for any processors that don't need to clean up
  ## any memory or other dynamic data.
  ##
  ## ``arg``: pointer to data to pass into
  ## the ``func``'s and ``done``'s ``udata`` parameter.
  ## This may be **nil**, depending on the processor.
  ##
  ## **Return** **false** on errors, such as a nonexisting channel.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.registerEffect(cint(channel), func, done, arg) == 0:
    echo(sdl.getError())
    return false
  return true


proc unregisterEffect(channel: int, func: TEffectFunc): bool =
  ## ``channel``: channel number to remove ``func`` from as a post processor.
  ## Use ``CHANNEL_POST`` for the postmix stream.
  ##
  ## ``func``: function to remove from ``channel``.
  ##
  ## **Return** **false** on errors, such as invalid channel,
  ## or effect function not registered on ``channel``.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.unregisterEffect(cint(channel), func) == 0:
    echo(sdl.getError())
    return false
  return true


proc unregisterAllEffects(channel: int): bool =
  ## ``channel``: channel to remove all effects from.
  ## Use ``CHANNEL_POST`` for the postmix stream.
  ##
  ## **Return** **false** on errors, such as ``channel`` not existing.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.unregisterAllEffects(cint(channel)) == 0:
    echo(sdl.getError())
    return false
  return true


proc setPostMix(func: TMixFunction, arg: Pointer) {.inline.} =
  ## ``func``: function pointer for the postmix processor.
  ## **Nil** unregisters the current postmixer.
  ##
  ## ``arg``: pointer to data to pass into the ``func``'s ``udata`` parameter.
  ## This may be **nil**, depending on the processor.
  ##
  ## See SDL_mixer documentation for details.
  sdl_mixer.setPostMix(func, arg)


proc setPanning(channel: int, left, right: byte): bool =
  ## ``channel``: channel number to register this effect on.
  ## Use ``CHANNEL_POST`` to process the postmix stream.
  ##
  ## ``left``: volume for the left channel (0..255).
  ##
  ## ``right``: volume for the right channel (0..255).
  ##
  ## This effect will only work on stereo audio (``DEFAULT_CHANNELS = 2``).
  ##
  ## **Note**: set both ``left`` and ``right`` to 255
  ## to unregister the effect from ``channel``.
  ##
  ## **Note**: using this on a mono audio device will not register the effect,
  ## nor will it return an error.
  ##
  ## **Return** **false** on errors, such as invalid channel,
  ## or if ``registerEffect`` failed.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.setPanning(cint(channel), left, right) == 0:
    echo(sdl.getError())
    return false
  return true


proc setDistance(channel: int, distance: byte): bool =
  ## ``channel``: channel number to register this effect on.
  ## Use ``CHANNEL_POST`` to process the postmix stream.
  ##
  ## ``distance``: distance from the listener (0..255).
  ##
  ## **Note**: set ``distance`` to 0
  ## to unregister effect from ``channel``.
  ##
  ## **Return** **false** on errors, such as invalid channel,
  ## or if ``registerEffect`` failed.
  ##
  ## See SLD_mixer documentation for details.
  if sdl_mixer.setDistance(cint(channel), distance) == 0:
    echo(sdl.getError())
    return false
  return true


proc setPosition(channel: int, angle: int, distance: byte): bool =
  ## ``channel``: channel number to register this effect on.
  ## Use ``CHANNEL_POST`` to process the postmix stream.
  ##
  ## ``angle``: direction in relation to forward from 0 to 360 degrees.
  ##
  ## ``distance``: distance from the listener (0..255).
  ##
  ## **Note**: set ``angle`` and ``distance`` to 0
  ## to unregister effect from ``channel``.
  ##
  ## **Return** **false** on errors, such as invalid channel,
  ## or if ``registerEffect`` failed.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.setPosition(cint(channel), int16(angle), distance) == 0:
    echo(sdl.getError())
    return false
  return true


proc setReverseStereo(channel: int, flip: int): bool =
  ## ``channel``: channel number to register this effect on.
  ## Use ``CHANNEL_POST`` to process the postmix stream.
  ##
  ## ``flip``: non-zero to work.
  ## Set to 0 to unregister effect from ``channel``.
  ##
  ## **Return** **false** on errors, such as invalid channel,
  ## or if ``registerEffect`` failed.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.setReverseStereo(cint(channel), cint(flip)) == 0:
    echo(sdl.getError())
    return false
  return true


# Music

proc free*(obj: var PMusic) {.inline.} =
  ## Free loaded music.
  sdl_mixer.freeMusic(obj)
  obj = nil


proc load*(obj: var PMusic, filename: string) {.inline.} =
  if obj != nil:
    sdl_mixer.freeMusic(obj)
    obj = nil
  obj = sdl_mixer.loadMUS(filename)


proc play*(obj: PMusic, loops: int = 0, fadein: int = 0) =
  ## Play loaded music.
  ## ``loops``: number of loops.
  ## ``fadein``: milliseconds of time for fade-in effect.
  if obj != nil:
    var ret: int = -1
    if fadein == 0:
      ret = sdl_mixer.playMusic(obj, cint(loops))
    else:
      ret = sdl_mixer.fadeInMusic(obj, cint(loops), cint(fadein))
    if ret < 0:
      echo(sdl.getError())


proc setMusicCMD(cmd: string): bool {.inline.} =
  ## Setup a command line music player to use to play music.
  ##
  ## **Return** **true** on succsee, or **false** on any errors.
  ##
  ## See SDL_mixer documentation for details.
  if sdl_mixer.setMusicCMD(cmd) != 0:
    echo(sdl.getError())
    return false
  return true


proc hookMusic*(func: TMixFunction, arg: Pointer) {.inline.} =
  ## Setup a custom music player function.
  ##
  ## ``func``: function pointer to a music player mixer function.
  ##
  ## ``arg``: pointer passed as ``func``'s ``udata`` parameter.
  ##
  ## See SDL_mixer documentation for details.
  sdl_mixer.hookMusic(func, arg)


proc getMusicHookData(): Pointer {.inline.} =
  ## Get ``arg`` pointer passed into ``hookMusic``.
  return sdl_mixer.getMusicHookData()


proc hookMusicFinished(callback: Pointer) {.inline.} =
  ## Setup a function to be called when music playback is halted.
  ## Call with **nil** to remove the callback.
  ##
  ## **Note**: NEVER call sld_mixer functions,
  ## nor sdl.lockAudio from a ``callback`` function.
  sdl_mixer.hookMusicFinished(callback)


proc musicVolume*(): int {.inline.} =
  ## Get music volume (0..128).
  return sdl_mixer.volumeMusic(-1)


proc `musicVolume=`*(value: int) {.inline.} =
  ## Set music volume (0..128)
  if value > 0:
    discard sdl_mixer.volumeMusic(cint(value))
  else:
    discard sdl_mixer.volumeMusic(0)


proc pauseMusic*() {.inline.} =
  ## Pause music playback.
  sdl_mixer.pauseMusic()


proc resumeMusic*() {.inline.} =
  ## Resume music playback. 
  sdl_mixer.resumeMusic()


proc toggleMusicPause*() =
  ## Pause music when playing or resume playing when paused.
  if sdl_mixer.pausedMusic() == 0: sdl_mixer.pauseMusic()
  else: sdl_mixer.resumeMusic()


proc rewindMusic*() {.inline.} =
  ## Rewind music to the start.
  ##
  ## **Note**: only works for MOD, OGG, MP3, Native MIDI.
  sdl_mixer.rewindMusic()


proc setMusicPos*(position: float): bool =
  ## Set ``position`` to play from.
  ##
  ## **Note**: only works for:
  ## * **MOD**: ``position`` is cast to ``Uint16``
  ##   and used for a pattern number in the module.
  ## * **OGG**: jumps to ``position`` seconds
  ##   from the ***beginning*** of the song.
  ## * **MP3**: jumps to ``position`` seconds
  ##   from the ***current position*** in the stream.
  ##   Negative values do nothing.
  ##
  ## **Return** **true** on success,
  ## or **false** if the codec doesn't support this function.
  if sdl_mixer.setMusicPosition(position) == 0:
    return true
  else:
    echo(sdl.getError())
    return false


proc haltMusic*() {.inline.} =
  ## Halt music playback.
  discard sdl_mixer.haltMusic()


proc fadeOutMusic*(ms: int) {.inline.} =
  ## Gradually fade out music over ``ms`` milliseconds starting from now.
  if sdl_mixer.fadeOutMusic(cint(ms)) != 1:
    echo(sdl.getError())


proc getMusicType*(obj: PMusic = nil): TMusicType {.inline.} =
  ## Get file format encoding of the music as ``TMusicType``.
  ## **Nil** for currently playing music type.
  return sdl_mixer.getMusicType(obj)


proc getMusicTypeStr*(obj: PMusic = nil): string =
  ## Get file format encoding of the music as ``string``.
  ## **Nil** for currently playing music type.
  let val = sdl_mixer.getMusicType(obj)
  case val
  of MUS_CMD: return "CMD"
  of MUS_WAV: return "WAV"
  of MUS_MOD: return "MOD"
  of MUS_MID: return "MID"
  of MUS_OGG: return "OGG"
  of MUS_MP3: return "MP3"
  else: return " "


proc musicPlaying*(): bool =
  ## Check if music playing or not.
  if sdl_mixer.playingMusic() == 0: return false
  else: return true


proc musicPaused*(): bool =
  ## Check if music paused or not.
  if sdl_mixer.pausedMusic() == 0: return false
  else: return true


proc getMusicFading*(): TFading {.inline.} =
  ## Get fadind status of music:
  ## * ``MIX_NO_FADING``
  ## * ``MIX_FADING_OUT``
  ## * ``MIX_FADING_IN``
  return sdl_mixer.fadingMusic()


# Callback


var musicFinishedCallbackProc: TCallback
var musicFinishedCallbackObject: PObject


proc musicFinishedCallback() =
  musicFinishedCallbackProc(musicFinishedCallbackObject, nil)


proc setMusicFinishedCallback*(callback: TCallback = nil,
                               callbackObject: PObject = nil) =
  ## Setup a callback to be called when music playback is halted.
  ##
  ## This proc is frontend to hookMusicFinished.
  ##
  ## ``callback``: callback function.
  ##
  ## ``callbackObject``: object to call.
  ##
  ## **Note**: NEVER call sld_mixer functions,
  ## nor sdl.lockAudio from a ``callback`` function.
  musicFinishedCallbackProc = callback
  musicFinishedCallbackObject = callbackObject
  hookMusicFinished(pointer(musicFinishedCallback))


# Playlist

type
  PPlaylist* = ref TPlaylist
  TPlaylist* = object of TObject
    tracks*: seq[tuple[file: string, title: string]]
    fCurrentMusic: PMusic
    fCurrentTrackIndex: int
    fCurrentTitle: string
    fFinished: bool
    shuffle*, repeat*, next*, playing*, paused*: bool


# TPlaylist methods


method currentMusic*(obj: PPlaylist): PMusic {.inline.} =
  ## Get reference to the currently playing music.
  return obj.fCurrentMusic


method currentTrackIndex*(obj: PPlaylist): int {.inline.} =
  ## Get current track index in ``tracks`` list.
  return obj.fCurrentTrackIndex


method currentTitle*(obj: PPlaylist): string {.inline.} =
  ## Get title of the current music.
  return obj.fCurrentTitle


method loadFromPath*(obj: PPlaylist, path: string) =
  ## Load tracks from given path (directory).
  if obj.tracks.len != 0:
    obj.tracks.setLen(0)
  for f in walkFiles(path/"*"):
    obj.tracks.add((file: f, title: splitFile(f).name))


method loadFromFile*(obj: PPlaylist, filename: string) =
  ## Load track from list in given file.
  if obj.tracks.len != 0:
    obj.tracks.setLen(0)
  if not existsFile(filename):
    echo("Error: playlist file \"", filename, "\" doesn't exist.")
    return
  var f: TFile
  if not open(f, filename):
    echo("Error: Can't open playlist file \"", filename, "\".")
    return
  if f == nil:
    return
  var s: TaintedString
  while true:
    try:
      s = readLine(f)
      echo s
      obj.tracks.add((file: s, title: splitFile(s).name))
    except:
      break
  close(f)


proc init*(obj: PPlaylist, shuffle, repeat, next: bool) =
  if(obj.tracks == nil):
    obj.tracks = @[]
  obj.shuffle = shuffle
  obj.repeat = repeat
  obj.next = next
  obj.playing = false
  obj.paused = false
  obj.fCurrentMusic = nil
  obj.fCurrentTrackIndex = -1
  obj.fCurrentTitle = " "
  obj.fFinished = false


method indexNext(obj: PPlaylist): int =
  ## Get index of the next track to be played.
  if obj.shuffle:
    return random(obj.tracks.len)
  else:
    if obj.fCurrentTrackIndex < obj.tracks.high and obj.fCurrentTrackIndex >= 0:
      return obj.fCurrentTrackIndex + 1
  return 0


method play*(obj: PPlaylist, index: int = -1) =
  ## Play specific track.
  ##
  ## ``index`` = -1 to play next track (``indexNext``).
  if obj.tracks.len < 1:
    return
  var idx: int
  if index < 0:
    idx = obj.indexNext()
  elif index > obj.tracks.high:
    idx = obj.tracks.high
  else:
    idx = index
  obj.fCurrentTrackIndex = idx
  obj.fCurrentTitle = obj.tracks[idx].title
  obj.fCurrentMusic.load(obj.tracks[idx].file)
  if obj.repeat:
    obj.fCurrentMusic.play(-1)
  else:
    obj.fCurrentMusic.play()


method playNext*(obj: PPlaylist) {.inline.} =
  ## Play next track.
  if obj.next: obj.play(-1)


method playTrack*(obj: PPlaylist, title: string = nil) =
  ## Play track with given ``title``.
  ##
  ## ``title`` = **nil** to play next track (``indexNext``).

  # get track index
  var index: int = -1
  if title == nil:
    index = obj.indexNext()
  else:
    for i in 0..obj.tracks.high:
      if title == obj.tracks[i].title:
        index = i
  # check for existance
  if index < 0:
    echo "Invalid track title: ", title
  else:
    obj.play(index)


proc nextCallback(obj: PObject, sender: PObject) =
  PPlaylist(obj).fFinished = true


method update*(obj: PPlaylist) =
  if obj.fFinished:
    obj.fFinished = false
    obj.playNext()


method free*(obj: PPlaylist) =
  nil


proc newPlaylist*(shuffle: bool = true,
                  repeat: bool = false,
                  next: bool = true,
                  defaultPlaylist: bool = true
                 ): PPlaylist =
  ## ``shuffle``: set random selection of the next track.
  ##
  ## ``next``: set auto-play next track.
  ##
  ## ``defaultPlaylist``: setup callback to play next track.
  new(result, free)
  init(result, shuffle, repeat, next)
  if defaultPlaylist:
    setMusicFinishedCallback(nextCallback, result)

