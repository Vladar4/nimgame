import
  sdl, sdl_ttf, sdl_gfx, sdl_mixer, math,
  common, screen, audio, state, timer, input, image, text, font

type
  PEngine* = ref TEngine
  TEngine* = object of TObject
    fRun: bool
    fScreen: TScreen
    fUpdateTimer, fInfoTimer: PTimer
    fUpdateInterval: int
    fFPSLimit: cint
    fInfoText: PText
    state*: PState
    info*, infobg*: bool
    bgColor*: int32

var FPSCounter, lastFPS: int
var FPSManager: TFPSManager

var game*: PEngine

# TEngine methods

method free*(obj: PEngine) =
  echo("Shutdown")
  if obj.state != nil: obj.state.free()
  freeScreenBuffer()
  sdl_mixer.closeAudio()
  sdl.quit()


# FPS

proc fpsLimit*(obj: PEngine): int {.inline.} =
  ## Get FPS limit.
  return int(obj.fFPSLimit)

proc `fpsLimit=`*(obj: PEngine, value: int = 60) =
  ## Set FPS limit. For unlimited FPS set to < 1.
  obj.fFPSLimit = cint(value)
  if obj.fFPSLimit > 0:
    check(setFramerate(addr(FPSManager), obj.fFPSLimit))


proc newEngine*(width: int = 640,   # screen width
                height: int = 480,  # screen height
                flags: int = 0,     # init flags
                scale: int = 1,     # screen scale rate
                title: cstring = "",  # window caption
                updateInterval: int = 20, # interval of update event in ms
                fpsLimit: int = 60, # frames per second limit (<1 - unlimited)
                info: bool = false, # show info
                infobg: bool = true, # info on black background
                bgColor: TColor = color(0, 0, 0), # screen background color
                audio: bool = true, # use audio system
                audioFrequency: cint = DEFAULT_FREQUENCY,
                audioFormat: int = DEFAULT_FORMAT,
                audioChannels: cint = DEFAULT_CHANNELS,
                audioChunkSize: cint = 1024
               ): PEngine =
  ## ``width``: screen width.
  ## 
  ## ``height``: screen height.
  ##
  ## ``flags``: init flags.
  ##
  ## ``scale``: screen scale rate (1 for no-scaling).
  ##
  ## ``title``: window caption.
  ##
  ## ``updateInterval``: interval of update event in ms.
  ##
  ## ``fpsLimit``: frames per second limit. For unlimited FPS set to < 1.
  ##
  ## ``info``: **true** to show info panel.
  ##
  ## ``infobg``: **true** to show info on black background.
  ##
  ## ``bgColor``: screen background color.
  ##
  ## ``audio``: **true** to use audio system.
  ##
  ## ``audioFrequency``: audio sampling frequency in samples per second (Hz).
  ##
  ## ``audioFromat``: audio sample format.
  ##
  ## ``audioChannels``: number of sound channels (2 for stereo, 1 for mono).
  ##
  ## ``audioChunkSize``: bytes used per sample.
  new(result, free)
  # screen setup
  result.fScreen.width = width * scale
  result.fScreen.height = height * scale
  result.fScreen.flags = flags
  result.fScreen.scale = scale
  # init
  if audio:
    check(sdl.init(INIT_VIDEO or INIT_AUDIO))
    check(sdl_mixer.openAudio(audioFrequency, uint16(audioFormat),
                              audioChannels, audioChunkSize))
  else:
    check(sdl.init(INIT_VIDEO))
  # ttf
  check(sdl_ttf.init())
  # screen
  result.fScreen.surface = check(setVideoMode(result.fScreen.width,
                                              result.fScreen.height,
                                              32, int32(flags)))
  initScreenBuffer(width, height, scale)
  result.bgColor = mapRGB(result.fScreen.surface.format,
                          bgColor.r, bgColor.g, bgColor.b)
  if title != "": WM_SetCaption(title, nil)
  # Update
  result.fUpdateInterval = updateInterval
  # Info
  result.info = info
  result.infobg = infobg
  result.fInfoText = newText(newBitmapFont("fnt/default8x16.png", 8, 16),
                                           x=4, y=2, " ")
  # FPSManager
  initFramerate(addr(FPSManager))
  result.fpsLimit = fpsLimit
  # randomize
  randomize()


# run
method run*(obj: PEngine): bool {.inline.} = return obj.fRun
method `run=`*(obj: PEngine, value: bool) {.inline.} = obj.fRun = value
method stop*(obj: PEngine) {.inline.} = obj.fRun = false


# switch info view
proc switchInfo*(obj: PEngine) {.inline.} =
  ## Turn on/off info panel.
  obj.info = not obj.info


# scale screen
proc scale(obj: PEngine) =
  let scr = screen()
  let pixels: PPixelArray = cast[PPixelArray](scr.pixels)
  var rect: TRect
  rect.w = uint16(obj.fScreen.scale)
  rect.h = uint16(obj.fScreen.scale)
  var offset: int = 0
  # scaling
  check(lockSurface(scr))
  rect.y = 0'i16
  for y in 0..scr.h-1:
    rect.x = 0'i16
    for x in 0..scr.w-1:
      check(obj.fScreen.surface.fillRect(addr(rect), int32(pixels[offset])))
      offset += 1
      rect.x = int16(rect.x + obj.fScreen.scale)
    rect.y = int16(rect.y + obj.fScreen.scale)
  unlockSurface(scr)


# flip screen
proc flip*(obj: PEngine) {.inline.} =
  check(flip(obj.fScreen.surface))


proc onUpdateTimer() =
  var event: TEvent
  var eventp: PEvent = addr(event)
  event.kind = TEventKind.USEREVENT
  EvUser(eventp).code = UE_UPDATE_TIMER
  EvUser(eventp).data1 = nil
  EvUser(eventp).data2 = nil
  check(pushEvent(addr(event)))


proc onInfoTimer() =
  lastFPS = FPSCounter
  FPSCounter = 0
  var event: TEvent
  var eventp: PEvent = addr(event)
  event.kind = TEventKind.USEREVENT
  EvUser(eventp).code = UE_UPDATE_INFO
  EvUser(eventp).data1 = nil
  EvUser(eventp).data2 = nil
  check(pushEvent(addr(event)))


# main cycle
proc start*(obj: PEngine) =
  ## Start main cycle.
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
    
    # FPS Delay
    if obj.fFPSLimit > 0:
      framerateDelay(addr(FPSManager))

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
        addButtonEvent(EvMouseButton(eventp).button.int, down)
      
      of MOUSEBUTTONUP:
        addButtonEvent(EvMouseButton(eventp).button.int, up)

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
    check(screen().fillRect(nil, obj.bgColor))
    obj.state.render()
    if infoUpd:
      infoUpd = false
      let entities = repr(obj.state.count)
      let l1 = "FPS: " & repr(lastFPS) & "    Entities: " & entities
      let l2 = "Mem.: " & repr(getTotalMem()) & " total (" & repr(getOccupiedMem()) & " occupied, " & repr(getFreeMem()) & " free)"
      obj.fInfoText.setText(l1, l2)
    # blit info
    if obj.info:
      if obj.infobg:
        var rect = obj.fInfoText.getRect()
        check(fillRect(screen(), addr(rect), 0))
      obj.fInfoText.blit()
    FPSCounter = FPSCounter + 1
    # flip screen
    if obj.fScreen.scale > 1: obj.scale()
    obj.flip()
    
