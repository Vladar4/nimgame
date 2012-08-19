include
  sdl_mixer

import
  common


# Sound

proc free*(obj: var PChunk) {.inline.} =
  freeChunk(obj)
  obj = nil


proc load*(obj: var PChunk, filename: string) {.inline.} =
  if obj != nil:
    freeChunk(obj)
    obj = nil
  obj = loadWAV(filename)


proc play*(obj: PChunk, channel: int = -1, loops: int = 0) {.inline.} =
  if obj != nil:
    if playChannel(cint(channel), obj, cint(loops)) < 0:
      echo(sdl.getError())

# Music

proc free*(obj: var PMusic) {.inline.} =
  freeMusic(obj)
  obj = nil


proc load*(obj: var PMusic, filename: string) {.inline.} =
  if obj != nil:
    freeMusic(obj)
    obj = nil
  obj = loadMUS(filename)


proc play*(obj: PMusic, loops: int = 0) {.inline.} =
  if obj != nil:
    check(playMusic(obj, cint(loops)))

