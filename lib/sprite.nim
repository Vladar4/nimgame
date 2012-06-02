import
  sdl, sdl_image, math,
  common, image, imageex

type

  TSpriteInfo = tuple[frames: seq[TRect], # sequence of frame rects
                      w, h: int,       # frame size
                      cols, rows: int] # frame grid dimensions

  PSprite* = ref TSprite
  TSprite* = object of TImageEx
    fSpritemap: PImage
    fSpriteInfo: TSpriteInfo
    fFrame: int


method changeFrame(obj: PSprite, frame: int) =
  obj.fFrame = frame
  var dstRect: TRect
  do(fillRect(obj.original, nil, 0))
  do(blitSurface(obj.fSpritemap.surface,
                 addr(obj.fSpriteInfo.frames[obj.fFrame]),
                 obj.original,
                 addr(dstRect)))
  obj.updateRotZoom()


proc init*(obj: PSprite,
           w: int = 0, h: int = 0,
           rows: int = 0, cols: int = 0,
           offsetX: int = 0, offsetY: int = 0,
          ) =
  obj.fSpriteInfo.frames = @[]
  if w > 0 and h > 0: # if width and height given
    obj.fSpriteInfo.w = w
    obj.fSpriteInfo.h = h
    obj.fSpriteInfo.cols = toInt(floor((obj.fSpritemap.surface.w - offsetX) / w))
    obj.fSpriteInfo.rows = toInt(floor((obj.fSpritemap.surface.h - offsetY) / h))
  elif rows > 0 and cols > 0: # if rows and columns count given
    obj.fSpriteInfo.rows = rows
    obj.fSpriteInfo.cols = cols
    obj.fSpriteInfo.w = toInt(floor((obj.fSpritemap.surface.w - offsetX) / cols))
    obj.fSpriteInfo.h = toInt(floor((obj.fSpritemap.surface.h - offsetY) / rows))
  else: # if no frame size or grid dimensions is given — make single frame
    obj.fSpriteInfo.w = obj.fSpritemap.surface.w - offsetX
    obj.fSpriteInfo.h = obj.fSpritemap.surface.h - offsetY
    obj.fSpriteInfo.cols = 1
    obj.fSpriteInfo.rows = 1
  # generate frame rects
  for col in 0..obj.fSpriteInfo.cols-1:
    for row in 0..obj.fSpriteInfo.rows-1:
      var rect: TRect
      rect.x = int16(offsetX + col * obj.fSpriteInfo.w)
      rect.y = int16(offsetY + row * obj.fSpriteInfo.h)
      rect.w = UInt16(obj.fSpriteInfo.w)
      rect.h = UInt16(obj.fSpriteInfo.h)
      obj.fSpriteInfo.frames.add(rect)
  # create surface
  obj.surface = newSurface(obj.fSpriteInfo.w, obj.fSpriteInfo.h)


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
  init(PImage(result), nil, int16(x), int16(y))
  result.fSpritemap = newImage(filename)
  init(result, w, h, rows, cols, offsetX, offsetY)
  init(PImageEx(result), smooth)
  result.changeFrame(0)

# get/set methods

method frame*(obj: PSprite): int {.inline.} = return obj.fFrame

method `frame=`*(obj: PSprite, value: int) {.inline.} =
  if value >= 0 and value <= obj.fSpriteInfo.frames.high():
    obj.changeFrame(value)
  else:
    echo("Warning: frame index out of range (", value, ").")


# usage: frame = [col, row]
method `frame=`*(obj: PSprite, value: openarray[int]) {.inline.} =
  if len(value) < 2:
    echo("Warning: not enough params for setting frame.")
    return
  let col = value[0]
  let row = value[1]
  if col >= 0 and col < obj.fSpriteInfo.cols and
     row >= 0 and row < obj.fSpriteInfo.rows:
    obj.changeFrame(col + row * obj.fSpriteInfo.cols)
  else:
    echo("Warning: frame index out of range (", value[0], ":", value[1], ").")

method width*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.w
method height*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.h
method cols*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.cols
method rows*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.rows
method count*(obj: PSprite): int {.inline.} = return obj.fSpriteInfo.frames.len()
