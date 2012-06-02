import sdl

let keystate: PKeyStateArr = cast[PKeyStateArr](getKeyState(nil))

type
  TKeyEventKind* = enum down, up
  TKeyEvent* = tuple[key: TKey, event: TKeyEventKind]

var keyevents: seq[TKeyEvent] = @[]


# check if key is pressed now
proc keyPressed*(key: TKey): bool {.inline.} =
  if keystate[int(key)] == 1: return true
  else: return false


proc resetKeyEvents*() {.inline.} =
  for i in countdown(keyevents.high, 0): keyevents.del(i)


proc addKeyEvent*(key: TKey, event: TKeyEventKind) {.inline.} =
  keyevents.add((key, event))


proc isKeyEvent*(key: TKey, event: TKeyEventKind): bool =
  for item in keyevents.items:
    if item.key == key:
      if item.event == event:
        return true
  return false


# check if was KEYDOWN event of this key since last update
template isKeyDown*(key: TKey): bool =
  isKeyEvent(key, down)


# check if was KEYUP event of this key since last update
template isKeyUp*(key: TKey): bool =
  isKeyEvent(key, up)