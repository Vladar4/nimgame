import
  sdl,
  common, screen

type
  TKeyEventKind* = enum down, up
  TKeyEvent* = tuple[key: TKey, event: TKeyEventKind]
  TButtonEvent* = tuple[button: int, event: TKeyEventKind]

let keystate: PKeyStateArr = cast[PKeyStateArr](getKeyState(nil))
var keyevents: seq[TKeyEvent] = @[]
var buttonevents: seq[TButtonEvent] = @[]
var buttonispressed: array[1..MAX_BUTTONS, bool]

proc resetKeyEvents*() {.inline.} =
  for i in countdown(keyevents.high, 0): keyevents.del(i)

proc resetButtonEvents*() {.inline.} =
  for i in countdown(buttonevents.high, 0): buttonevents.del(i)


proc addKeyEvent*(key: TKey, event: TKeyEventKind) {.inline.} =
  keyevents.add((key, event))


proc addButtonEvent*(btn: int, event: TKeyEventKind) {.inline.} =
  buttonevents.add((btn, event))
  if event == down: buttonispressed[btn] = true
  else: buttonispressed[btn] = false


proc isKeyEvent*(key: TKey, event: TKeyEventKind): bool =
  for item in keyevents.items:
    if item.key == key:
      if item.event == event:
        return true
  return false


proc isButtonEvent*(btn: int, event: TKeyEventKind): bool =
  for item in buttonevents.items:
    if item.button == btn:
      if item.event == event:
        return true
  return false


# check if key is pressed now
proc keyPressed*(key: TKey): bool {.inline.} =
  if keystate[int(key)].int == 1: return true
  else: return false


# check if was KEYDOWN event of this key since last update
template isKeyDown*(key: TKey): bool =
  isKeyEvent(key, down)


# check if was KEYUP event of this key since last update
template isKeyUp*(key: TKey): bool =
  isKeyEvent(key, up)


# check if mouse button is pressed now
proc buttonPressed*(btn: int): bool {.inline.} =
  return buttonispressed[btn]


# check if was MOUSEBUTTONDOWN event of this button since last update
template isButtonDown*(btn: int): bool =
  isButtonEvent(btn, down)


# check if was MOUSEBUTTONUP event of this button since last update
template isButtonUp*(btn: int): bool =
  isKeyEvent(btn, up)


# get mouse position
proc mousePos*(): TPoint {.inline.} =
  var x, y: int
  discard getMouseState(x, y)
  if screenScale() == 1:
    result.x = int16(x)
    result.y = int16(y)
  else:
    result.x = int16(x / screenScale())
    result.y = int16(y / screenScale())

# get relative mouse position
proc mouseRelativePos*(): TPoint {.inline.} =
  var x, y: int
  discard getRelativeMouseState(x, y)
  if screenScale() == 1:
    result.x = int16(x)
    result.y = int16(y)
  else:
    result.x = int16(x / screenScale())
    result.y = int16(y / screenScale())
