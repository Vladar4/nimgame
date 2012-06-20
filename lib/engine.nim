import
  sdl, sdl_ttf, sdl_gfx, math,
  common, state, timer, input, image, text, font

type
  
  TScreen* = tuple[surface: PSurface,
                   width, height, bpp, flags: int32]

  PEngine* = ref TEngine
  TEngine* = object of TObject
    fRun: bool
    fScreen: TScreen
    fUpdateTimer, fFPSTimer: PTimer
    fUpdateInterval: int32
    fFPSText: PText
    state*: PState
    fps*: bool
    bgColor*: int32

var FPSCounter, lastFPS: int

var game*: PEngine

# TEngine methods

method free*(obj: PEngine) =
  echo("Shutdown")
  if obj.state != nil: obj.state.free()
  sdl.quit()


proc newEngine*(width: int32 = 640,   # screen width
                height: int32 = 480,  # screen height
                bpp: int32 = 32,      # bits per pixel
                flags: int32 = 0,     # init flags
                title: cstring = "",  # window caption
                updateInterval: int32 = 20, # interval of update event in ms
                fps: bool = false, # show FPS
                bgColor: TColor = color(0, 0, 0), # background color
               ): PEngine =
  new(result, free)
  # screen setup
  result.fScreen.width = width
  result.fScreen.height = height
  result.fScreen.BPP = bpp
  result.fScreen.flags = flags
  # init
  do(sdl.init(INIT_VIDEO))
  do(sdl_ttf.init())
  result.fScreen.surface = do(setVideoMode(width, height, bpp, flags))
  result.bgColor = mapRGB(result.fScreen.surface.format, bgColor.r, bgColor.g, bgColor.b)
  if title != "": WM_SetCaption(title, nil)
  # Update
  result.fUpdateInterval = updateInterval
  # FPS
  result.fps = fps
  result.fFPSText = newText(newBitmapFont("fnt/default8x16.png", 8, 16), x=4, y=2, text=" ")
  # randomize
  randomize()


# run
method run*(obj: PEngine): bool {.inline.} = return obj.fRun
method `run=`*(obj: PEngine, value: bool) {.inline.} = obj.fRun = value
method stop*(obj: PEngine) {.inline.} = obj.fRun = false


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


proc onFPSTimer() =
  lastFPS = FPSCounter
  FPSCounter = 0
  var event: TEvent
  var eventp: PEvent = addr(event)
  event.kind = TEventKind.USEREVENT
  EvUser(eventp).code = UE_UPDATE_FPS
  EvUser(eventp).data1 = nil
  EvUser(eventp).data2 = nil
  do(pushEvent(addr(event)))
  

# main cycle
proc start*(obj: PEngine) =
  var event: TEvent
  obj.fRun = true
  # update timer
  obj.fUpdateTimer = newTimer(obj.fUpdateInterval, onUpdateTimer)
  # FPS timer
  var fpsUpd: bool = false
  FPSCounter = 0
  lastFPS = 0
  obj.fFPSTimer = newTimer(1000, onFPSTimer)
  # state update
  var update: bool = false
  
  while obj.fRun:
    
    # update timers
    obj.fUpdateTimer.update()
    if obj.fps: obj.fFPSTimer.update()
    
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
        of UE_UPDATE_FPS: fpsUpd = true
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
    if fpsUpd:
      fpsUpd = false
      obj.fFPSText.text = "FPS: " & repr(lastFPS) & "    Entities: " & repr(obj.state.count)
    # blit FPS
    if obj.fps: obj.fFPSText.blit()
    FPSCounter = FPSCounter + 1
    # flip screen
    obj.flip()
