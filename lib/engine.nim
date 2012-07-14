import
  sdl, sdl_ttf, sdl_gfx, math,
  common, screen, state, timer, input, image, text, font

type
  
  TScreen* = tuple[surface: PSurface,
                   width, height, flags: int32, scale: UInt16]

  PEngine* = ref TEngine
  TEngine* = object of TObject
    fRun: bool
    fScreen: TScreen
    fUpdateTimer, fInfoTimer: PTimer
    fUpdateInterval: int32
    fInfoText: PText
    state*: PState
    info*: bool
    bgColor*: int32

var FPSCounter, lastFPS: int

var game*: PEngine

# TEngine methods

method free*(obj: PEngine) =
  echo("Shutdown")
  if obj.state != nil: obj.state.free()
  freeScreenBuffer()
  sdl.quit()


proc newEngine*(width: int32 = 640,   # screen width
                height: int32 = 480,  # screen height
                flags: int32 = 0,     # init flags
                scale: int32 = 1,     # screen scale rate
                title: cstring = "",  # window caption
                updateInterval: int32 = 20, # interval of update event in ms
                info: bool = false, # show info
                bgColor: TColor = color(0, 0, 0), # background color
               ): PEngine =
  new(result, free)
  # screen setup
  result.fScreen.width = width * scale
  result.fScreen.height = height * scale
  result.fScreen.flags = flags
  result.fScreen.scale = toU16(scale)
  # init
  do(sdl.init(INIT_VIDEO))
  do(sdl_ttf.init())
  result.fScreen.surface = do(setVideoMode(result.fScreen.width, result.fScreen.height,
                                           32, flags))
  initScreenBuffer(width, height, scale)
  result.bgColor = mapRGB(result.fScreen.surface.format, bgColor.r, bgColor.g, bgColor.b)
  if title != "": WM_SetCaption(title, nil)
  # Update
  result.fUpdateInterval = updateInterval
  # Info
  result.info = info
  result.fInfoText = newText(newBitmapFont("fnt/default8x16.png", 8, 16), x=4, y=2, text=" ")
  # randomize
  randomize()


# run
method run*(obj: PEngine): bool {.inline.} = return obj.fRun
method `run=`*(obj: PEngine, value: bool) {.inline.} = obj.fRun = value
method stop*(obj: PEngine) {.inline.} = obj.fRun = false

# switch info view
proc switchInfo*(obj: PEngine) {.inline.} =
  obj.info = not obj.info


# scale screen
proc scale(obj: PEngine) =
  let scr = screen()
  let pixels: PPixelArray = cast[PPixelArray](scr.pixels)
  var rect: TRect
  rect.w = obj.fScreen.scale
  rect.h = obj.fScreen.scale
  var offset: int = 0
  # scaling
  do(lockSurface(scr))
  rect.y = 0'i16
  for y in 0..scr.h-1:
    rect.x = 0'i16
    for x in 0..scr.w-1:
      do(obj.fScreen.surface.fillRect(addr(rect), pixels[offset]))
      offset += 1
      rect.x = rect.x + obj.fScreen.scale
    rect.y = rect.y + obj.fScreen.scale
  unlockSurface(scr)


# flip screen
proc flip*(obj: PEngine) {.inline.} =
  do(flip(obj.fScreen.surface))


proc onUpdateTimer() =
  var event: TEvent
  var eventp: PEvent = addr(event)
  event.kind = TEventKind.USEREVENT
  EvUser(eventp).code = UE_UPDATE_TIMER
  EvUser(eventp).data1 = nil
  EvUser(eventp).data2 = nil
  do(pushEvent(addr(event)))


proc onInfoTimer() =
  lastFPS = FPSCounter
  FPSCounter = 0
  var event: TEvent
  var eventp: PEvent = addr(event)
  event.kind = TEventKind.USEREVENT
  EvUser(eventp).code = UE_UPDATE_INFO
  EvUser(eventp).data1 = nil
  EvUser(eventp).data2 = nil
  do(pushEvent(addr(event)))


# main cycle
proc start*(obj: PEngine) =
  var event: TEvent
  obj.fRun = true
  # update timer
  obj.fUpdateTimer = newTimer(obj.fUpdateInterval, onUpdateTimer)
  # Info timer
  var infoUpd: bool = false
  FPSCounter = 0
  lastFPS = 0
  obj.fInfoTimer = newTimer(1000, onInfoTimer)
  # state update
  var update: bool = false
  
  while obj.fRun:
    
    # update timers
    obj.fUpdateTimer.update()
    if obj.info: obj.fInfoTimer.update()
    
    while pollEvent(addr(event)) == 1:
      let eventp = addr(event)
      case event.kind:
    
      of QUITEV:
        obj.fRun = false
        break
      
      of KEYDOWN:
        addKeyEvent(EvKeyboard(eventp).keysym.sym, down)
      
      of KEYUP:
        addKeyEvent(EvKeyboard(eventp).keysym.sym, up)
      
      of MOUSEBUTTONDOWN:
        addButtonEvent(EvMouseButton(eventp).button, down)
      
      of MOUSEBUTTONUP:
        addButtonEvent(EvMouseButton(eventp).button, up)

      of USEREVENT:
        case EvUser(eventp).code:
        of UE_UPDATE_TIMER: update = true
        of UE_UPDATE_INFO: infoUpd = true
        else: nil
      
      else: nil
    
    if update:
      update = false
      if obj.state != nil: obj.state.update()
      resetKeyEvents()
      resetButtonEvents()
    
    # render
    do(screen().fillRect(nil, obj.bgColor))
    obj.state.render()
    if infoUpd:
      infoUpd = false
      obj.fInfoText.text = ["FPS: " & repr(lastFPS) & "    Entities: " & repr(obj.state.count),
                            "Mem.: " & repr(getTotalMem()) & " total (" & repr(getOccupiedMem()) & " occupied, " & repr(getFreeMem()) & " free)"]
    # blit info
    if obj.info: obj.fInfoText.blit()
    FPSCounter = FPSCounter + 1
    # flip screen
    if obj.fScreen.scale > 1: obj.scale()      
    obj.flip()
