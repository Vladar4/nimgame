import
  os, math,
  sdl, sdl_mixer,
  common


# Sound/channels/chunks

proc setChannels*(num: int) {.inline.} =
  check(sdl_mixer.allocateChannels(cint(num)))


# set volume of channel
# channel = -1: for all channels
# volume range: 0..128
proc setAudioVolume*(volume: int, channel: int = -1) {.inline.} =
  discard sdl_mixer.volume(cint(channel), cint(volume))


# get volume of channel
# channel = -1: average volume of all channels
proc getAudioVolume*(channel: int = -1): int {.inline.} =
  return sdl_mixer.volume(cint(channel), -1)


proc getChunk*(channel: int): PChunk =
  if channel < 0: return nil
  return sdl_mixer.getChunk(cint(channel))


proc free*(obj: var PChunk) {.inline.} =
  sdl_mixer.freeChunk(obj)
  obj = nil


proc load*(obj: var PChunk, filename: string) {.inline.} =
  if obj != nil:
    sdl_mixer.freeChunk(obj)
    obj = nil
  obj = sdl_mixer.loadWAV(filename)


# play chunk
# loops: number of loops
# timed: millisecond limit to play sample, at most
# fadein: milliseconds of time for fade-in effect
proc play*(obj: PChunk, channel: int = -1, loops: int = 0,
           timed: int = 0, fadein: int = 0) {.inline.} =
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
  sdl_mixer.channelFinished(callback)


proc pauseChannel*(channel: int = -1) {.inline.} =
  sdl_mixer.pause(cint(channel))


proc resumeChannel*(channel: int = -1) {.inline.} =
  sdl_mixer.resume(cint(channel))


proc toggleChannelPause*(channel: int = -1) =
  if sdl_mixer.paused(cint(channel)) == 0: sdl_mixer.pause(cint(channel))
  else: sdl_mixer.resume(cint(channel))


proc channelPaused*(channel: int = -1): bool =
  if sdl_mixer.paused(cint(channel)) == 0: return false
  else: return true


proc pausedChannelsCount*(): int {.inline.} =
  return sdl_mixer.paused(-1)


proc haltChannel*(channel: int = -1) {.inline.} =
  discard sdl_mixer.haltChannel(cint(channel))


proc expireChannel*(channel, ticks: int): int {.inline.} =
  return sdl_mixer.expireChannel(cint(channel), cint(ticks))


proc fadeOutChannel*(channel, ms: int): int {.inline.} =
  return sdl_mixer.fadeOutChannel(cint(channel), cint(ms))


proc getChannelFading*(channel: int): TFading {.inline.} =
  return sdl_mixer.fadingChannel(cint(channel))


proc channelPlaying*(channel: int = -1): bool =
  if sdl_mixer.playing(cint(channel)) == 0: return false
  else: return true


proc playingChannelsCount*(): int {.inline.} =
  return sdl_mixer.playing(-1)


proc volume*(obj: PChunk): int {.inline.} =
  return sdl_mixer.volumeChunk(obj, -1)


proc `volume=`*(obj: PChunk, value: int) {.inline.} =
  if value > 0:
    discard sdl_mixer.volumeChunk(obj, cint(value))
  else:
    discard sdl_mixer.volumeChunk(obj, 0)


# Groups

proc reserveChannels*(num: int): int {.inline.} =
  return sdl_mixer.reserveChannels(cint(num))


proc groupChannel*(channel, tag: int): bool =
  if sdl_mixer.groupChannel(cint(channel), cint(tag)) != 1:
    echo(sdl.getError())
    return false
  else: return true


proc groupChannels*(fromChannel, toChannel, tag: int): int {.inline.} =
  return sdl_mixer.groupChannels(cint(fromChannel), cint(toChannel), cint(tag))


# return number of channels in group
# -1 will count all channels
proc groupCount*(tag: int): int {.inline.} =
  return sdl_mixer.groupCount(cint(tag))


proc groupAvailable*(tag: int): int {.inline.} =
  return sdl_mixer.groupAvailable(cint(tag))


proc groupOldest*(tag: int): int {.inline.} =
  return sdl_mixer.groupOldest(cint(tag))


proc groupNewer*(tag: int): int {.inline.} =
  return sdl_mixer.groupNewer(cint(tag))


proc fadeOutGroup*(tag, ms: int): int {.inline.} =
  return sdl_mixer.fadeOutGroup(cint(tag), cint(ms))


proc haltGroup*(tag: int) {.inline.} =
  discard sdl_mixer.haltGroup(cint(tag))


# Music

proc free*(obj: var PMusic) {.inline.} =
  sdl_mixer.freeMusic(obj)
  obj = nil


proc load*(obj: var PMusic, filename: string) {.inline.} =
  if obj != nil:
    sdl_mixer.freeMusic(obj)
    obj = nil
  obj = sdl_mixer.loadMUS(filename)


# play music
# loops: number of loops
# fadein: milliseconds of time for fade-in effect
proc play*(obj: PMusic, loops: int = 0, fadein: int = 0) =
  if obj != nil:
    var ret: int = -1
    if fadein == 0:
      ret = sdl_mixer.playMusic(obj, cint(loops))
    else:
      ret = sdl_mixer.fadeInMusic(obj, cint(loops), cint(fadein))
    if ret < 0:
      echo(sdl.getError())


proc setMusicCMD(cmd: string) {.inline.} =
  if sdl_mixer.setMusicCMD(cmd) != 0: echo(sdl.getError())


proc hookMusic*(callback: TMixFunction, arg: Pointer) {.inline.} =
  sdl_mixer.hookMusic(callback, arg)


proc getMusicHookData(): Pointer {.inline.} =
  return sdl_mixer.getMusicHookData()


proc hookMusicFinished(callback: Pointer) {.inline.} =
  sdl_mixer.hookMusicFinished(callback)


proc musicVolume*(): int {.inline.} =
  return sdl_mixer.volumeMusic(-1)


proc `volume=`*(value: int) {.inline.} =
  if value > 0:
    discard sdl_mixer.volumeMusic(cint(value))
  else:
    discard sdl_mixer.volumeMusic(0)


proc pauseMusic*() {.inline.} =
  sdl_mixer.pauseMusic()


proc resumeMusic*() {.inline.} =
  sdl_mixer.resumeMusic()


proc toggleMusicPause*() =
  if sdl_mixer.pausedMusic() == 0: sdl_mixer.pauseMusic()
  else: sdl_mixer.resumeMusic()


proc rewindMusic*() {.inline.} =
  sdl_mixer.rewindMusic()


proc setMusicPos*(pos: float): bool =
  if sdl_mixer.setMusicPosition(pos) == 0:
    return true
  else:
    echo(sdl.getError())
    return false


proc haltMusic*() {.inline.} =
  discard sdl_mixer.haltMusic()


proc fadeOutMusic*(ms: int) {.inline.} =
  if sdl_mixer.fadeOutMusic(cint(ms)) != 1:
    echo(sdl.getError())


proc getMusicType*(obj: PMusic = nil): TMusicType {.inline.} =
  return sdl_mixer.getMusicType(obj)


proc getMusicTypeStr*(obj: PMusic = nil): string =
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
  if sdl_mixer.playingMusic() == 0: return false
  else: return true


proc musicPaused*(): bool =
  if sdl_mixer.pausedMusic() == 0: return false
  else: return true


proc getMusicFading*(): TFading {.inline.} =
  return sdl_mixer.fadingMusic()


# Playlist

type
  PPlaylist* = ref TPlaylist
  TPlaylist* = object of TObject
    tracks*: seq[tuple[file: string, name: string]]
    fCurrentMusic*: PMusic
    fCurrentTrackNum*: int
    fCurrentTitle*: string
    shuffle*, repeat*, next*, playing*, paused*: bool


# TPlaylist methods


method currentMusic*(obj: PPlaylist): PMusic {.inline.} =
  return obj.fCurrentMusic


method currentTrackNum*(obj: PPlaylist): int {.inline.} =
  return obj.fCurrentTrackNum


method currentTitle*(obj: PPlaylist): string {.inline.} =
  return obj.fCurrentTitle


method loadFromPath*(obj: PPlaylist, path: string) =
  if obj.tracks.len != 0:
    obj.tracks.setLen(0)
  for f in walkFiles(path/"*"):
    obj.tracks.add((file: f, name: splitFile(f).name))


method loadFromFile*(obj: PPlaylist, path: string) =
  nil


proc init*(obj: PPlaylist,
           shuffle, repeat, next: bool) =
  if(obj.tracks == nil):
    obj.tracks = @[]
  obj.shuffle = shuffle
  obj.repeat = repeat
  obj.next = next
  obj.playing = false
  obj.paused = false
  obj.fCurrentMusic = nil
  obj.fCurrentTrackNum = -1
  obj.fCurrentTitle = " "


method play*(obj: PPlaylist, track: string = nil) =
  # get track index
  var index: int = -1
  if track == nil:
    index = random(obj.tracks.len)
  else:
    for i in 0..obj.tracks.high:
      if track == obj.tracks[i].name:
        index = i
  # check for existance
  if index < 0:
    echo "Invalid track name"
  else:
    # load and play track
    obj.fCurrentTrackNum = index
    obj.fCurrentTitle = obj.tracks[index].name
    obj.fCurrentMusic.load(obj.tracks[index].file)
    if obj.repeat:
      obj.fCurrentMusic.play(-1)
    else:
      obj.fCurrentMusic.play()


method free*(obj: PPlaylist) =
  nil


proc newPlaylist*(shuffle: bool = true,
                  repeat: bool = false,
                  next: bool = true,
                 ): PPlaylist =
  new(result, free)
  init(result, shuffle, repeat, next)

