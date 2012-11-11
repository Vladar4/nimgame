import
  sdl,
  common, screen

type
  TKeyEventKind* = enum down, up ## keyboard key event kind
  TKeyEvent* = tuple[key: TKey, event: TKeyEventKind] ## keyboard key event
  TButtonEvent* = tuple[button: int, event: TKeyEventKind] ## mouse button event

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


proc keyPressed*(key: TKey): bool {.inline.} =
  ## Check if ``key`` is pressed now.
  if keystate[int(key)].int == 1: return true
  else: return false


template isKeyDown*(key: TKey): bool =
  ## Check if was ``KEYDOWN`` event of this ``key`` since last update.
  isKeyEvent(key, down)


template isKeyUp*(key: TKey): bool =
  ## Check if was ``KEYUP`` event of this ``key`` since last update.
  isKeyEvent(key, up)


proc buttonPressed*(btn: int): bool {.inline.} =
  ## Check if mouse button ``btn`` is pressed now.
  return buttonispressed[btn]


template isButtonDown*(btn: int): bool =
  ## Check if was ``MOUSEBUTTONDOWN`` event of mouse button ``btn``
  ## since last update.
  isButtonEvent(btn, down)


template isButtonUp*(btn: int): bool =
  ## Check if was ``MOUSEBUTTONUP`` event of mouse button ``btn``
  ## since last update.
  isButtonEvent(btn, up)


proc mousePos*(): TPoint {.inline.} =
  ## Get mouse position.
  var x, y: int
  discard getMouseState(x, y)
  if screenScale() == 1:
    result.x = int16(x)
    result.y = int16(y)
  else:
    result.x = int16(x / screenScale())
    result.y = int16(y / screenScale())


proc mouseRelativePos*(): TPoint {.inline.} =
  ## Get relative mouse position.
  var x, y: int
  discard getRelativeMouseState(x, y)
  if screenScale() == 1:
    result.x = int16(x)
    result.y = int16(y)
  else:
    result.x = int16(x / screenScale())
    result.y = int16(y / screenScale())

