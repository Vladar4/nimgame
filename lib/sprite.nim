import
  sdl, sdl_image,
  unsigned, math,
  common, screen, image, imageex

type

  TSpriteInfo* = tuple[frames: seq[TRect], # sequence of frame rects
                      w, h: uint16,        # frame size
                      cols, rows: int]     # frame grid dimensions


  TAnimationAction* = enum doNothing, setFirstFrame, deleteEntity

  PSprite* = ref TSprite
  TSprite* = object of TImageEx
    fSpritemap: PImage
    fSpriteInfo: TSpriteInfo
    fFrame: int
    play*, loop*: bool
    animFrames: seq[int]
    animIndex: int
    animRate*, animRateCounter: int
    animAction*: TAnimationAction


# Fill sprite map with given color but save alpha channel
method maskedFill*(obj: PSprite, color: TColor) =
  let colorize = newSurface(obj.fSpritemap.surface.w, obj.fSpritemap.surface.h, true)
  check(colorize.fillRect(nil, mapRGBA(colorize.format, color.r, color.g, color.b, 255)))
  check(colorize.blitSurface(nil, obj.fSpritemap.surface, nil))
  freeSurface(colorize)


# Blit single frame to the given surface without changing current frame
method blitFrame*(obj: PSprite, frame: int, dstSurface: PSurface,
                  x: int16 = 0'i16, y: int16 = 0'i16) =
  var dstRect: TRect
  dstRect.x = x
  dstRect.y = y
  dstRect.w = obj.fSpriteInfo.w
  dstRect.h = obj.fSpriteInfo.h
  check(blitSurfaceAlpha(obj.fSpritemap.surface,
                         addr(obj.fSpriteInfo.frames[frame]),
                         dstSurface,
                         addr(dstRect)))


method changeFrame(obj: PSprite, frame: int) =
  obj.fFrame = frame
  var dstRect: TRect
  check(fillRect(obj.original, nil, 0))
  check(blitSurfaceAlpha(obj.fSpritemap.surface,
                         addr(obj.fSpriteInfo.frames[obj.fFrame]),
                         obj.original,
                         addr(dstRect)))
  obj.updateRotZoom()


proc init*(obj: PSprite,
           w: uint16 = 0, h: uint16 = 0,
           rows: int = 0, cols: int = 0,
           offsetX: int = 0, offsetY: int = 0,
          ) =
  obj.fSpriteInfo.frames = @[]
  if w > 0'u16 and h > 0'u16: # if width and height given
    obj.fSpriteInfo.w = w
    obj.fSpriteInfo.h = h
    obj.fSpriteInfo.cols = int(floor(float(obj.fSpritemap.surface.w - offsetX) / float(w)))
    obj.fSpriteInfo.rows = int(floor(float(obj.fSpritemap.surface.h - offsetY) / float(h)))
  elif rows > 0 and cols > 0: # if rows and columns count given
    obj.fSpriteInfo.rows = rows
    obj.fSpriteInfo.cols = cols
    obj.fSpriteInfo.w = uint16(floor((obj.fSpritemap.surface.w - offsetX) / cols))
    obj.fSpriteInfo.h = uint16(floor((obj.fSpritemap.surface.h - offsetY) / rows))
  else: # if no frame size or grid dimensions is given — make single frame
    obj.fSpriteInfo.w = uint16(obj.fSpritemap.surface.w - offsetX)
    obj.fSpriteInfo.h = uint16(obj.fSpritemap.surface.h - offsetY)
    obj.fSpriteInfo.cols = 1
    obj.fSpriteInfo.rows = 1
  # check spritemap size
  if obj.fSpriteInfo.w > uint16(obj.fSpritemap.surface.w) or
     obj.fSpriteInfo.h > uint16(obj.fSpritemap.surface.h):
      echo("Error: spritemap size is too small")
  # generate frame rects
  for row in 0..obj.fSpriteInfo.rows-1:
    for col in 0..obj.fSpriteInfo.cols-1:
      var rect: TRect
      rect.x = int16(offsetX + col * int(obj.fSpriteInfo.w))
      rect.y = int16(offsetY + row * int(obj.fSpriteInfo.h))
      rect.w = obj.fSpriteInfo.w
      rect.h = obj.fSpriteInfo.h
      obj.fSpriteInfo.frames.add(rect)
  # create surface
  freeSurface(obj.surface)
  obj.surface = newSurface(obj.fSpriteInfo.w, obj.fSpriteInfo.h, true)
  obj.play = false
  obj.loop = false
  obj.animFrames = @[0]
  obj.animIndex = 0
  obj.animRate = 1
  obj.animRateCounter = 0


proc free*(obj: PSprite) =
  PImage(obj).free()


proc newSprite*(filename: cstring,
                x: int = 0, # x draw offset
                y: int = 0, # y draw offset
                w: int = 0, # frame width
                h: int = 0, # frame height
                rows: int = 0,  # frame grid rows
                cols: int = 0,  # frame grid cols
                offsetX: int = 0, # x frame grid offset
                OffsetY: int = 0, # y frame grid offset
                smooth: cint = 1, # smooth
               ): PSprite =
  new(result, free)
  init(PImage(result), "", x, y)
  result.fSpritemap = newImage(filename)
  init(result, uint16(w), uint16(h), rows, cols, offsetX, offsetY)
  init(PImageEx(result), smooth)
  result.changeFrame(0)


proc newSprite*(surface: PSurface,
                x: int = 0, # x draw offset
                y: int = 0, # y draw offset
                w: int = 0, # frame width
                h: int = 0, # frame height
                rows: int = 0,  # frame grid rows
                cols: int = 0,  # frame grid cols
                offsetX: int = 0, # x frame grid offset
                OffsetY: int = 0, # y frame grid offset
                smooth: cint = 1, # smooth
               ): PSprite =
  new(result, free)
  init(PImage(result), "", x, y)
  result.fSpritemap = newImage(surface)
  init(result, uint16(w), uint16(h), rows, cols, offsetX, offsetY)
  init(PImageEx(result), smooth)
  result.changeFrame(0)


# get/set methods

method frame*(obj: PSprite): int {.inline.} = return obj.fFrame

method `frame=`*(obj: PSprite, value: int) {.inline.} =
  if value != obj.fFrame:
    if value >= 0 and value <= obj.fSpriteInfo.frames.high():
      obj.changeFrame(value)
    else:
      echo("Warning: frame index out of range (", value, ").")


# usage: frame = [col, row]
method `frame=`*(obj: PSprite, value: varargs[int]) {.inline.} =
  if len(value) < 2:
    echo("Warning: not enough params for setting frame.")
    return
  let col = value[0]
  let row = value[1]
  let frame = col + row * obj.fSpriteInfo.cols
  if frame != obj.fFrame:
    if col >= 0 and col < obj.fSpriteInfo.cols and
       row >= 0 and row < obj.fSpriteInfo.rows:
      obj.changeFrame(frame)
    else:
      echo("Warning: frame index out of range (", value[0], ":", value[1], ").")

method w*(obj: PSprite): int {.inline.} = return int(obj.fSpriteInfo.w)
method h*(obj: PSprite): int {.inline.} = return int(obj.fSpriteInfo.h)
method cols*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.cols
method rows*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.rows
method count*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.frames.len()


# animation
method setAnimation*(obj: PSprite,
                     frames: seq[int], rate: int = 1,
                     loop: bool = false, play: bool = true,
                     action: TAnimationAction = doNothing) =
  if frames.len < 1:
    obj.frame = 0
    return
  obj.frame = frames[0]
  obj.animFrames = frames
  obj.animRate = rate
  obj.animRateCounter = 0
  obj.loop = loop
  obj.play = play
  obj.animAction = action

method setAnimation*(obj: PSprite,
                     first: int = 0, last: int = -1, rate: int = 1,
                     loop: bool = false, play: bool = true,
                     action: TAnimationAction = doNothing) =
  var frames: seq[int] = @[]
  if last < 0:
    for i in first..obj.fSpriteInfo.frames.high:
      frames.add(i)
  else:
    for i in first..last:
      frames.add(i)
  obj.setAnimation(frames, rate, loop, play, action)
  

# update

proc updateSprite*(obj: PSprite) =
  if obj.play:
    if obj.animIndex >= obj.animFrames.high and
       obj.animRateCounter >= obj.animRate - 1:
      obj.animRateCounter = 0
      if obj.loop: # start new cycle
        obj.animIndex = 0
      else: # stop animation
        obj.play = false
        case obj.animAction:
        of doNothing: nil
        of setFirstFrame: obj.animIndex = 0
        of deleteEntity: obj.deleteEntity = true
    else: # next frame
      if obj.animRate == 1:
        obj.animIndex += 1
      else:
        if obj.animRateCounter < obj.animRate - 1:
          obj.animRateCounter = obj.animRateCounter + 1
        else:
          obj.animRateCounter = 0
          obj.animIndex += 1
    obj.frame = obj.animFrames[obj.animIndex]


method update*(obj: PSprite) {.inline.} =
  obj.updateSprite()
