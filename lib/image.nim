import
  sdl, sdl_image,
  common

type

  PImage* = ref TImage
  TImage* = object of TObject
    x*, y*: int16
    surface*: PSurface


# TImage methods

proc init*(obj: PImage,
           filename: cstring,
           x: int16 = 0'i16,
           y: int16 = 0'i16,
          ) =
  # set position
  obj.x = x
  obj.y = y
  # load image
  if filename != nil:
    let surface: PSurface = do(imgLoad(filename))
    obj.surface = displayFormatAlpha(surface)
    freeSurface(surface)


method free*(obj: PImage) =
  freeSurface(obj.surface)


proc newImage*(filename: cstring,
               x: int = 0,  # x draw offset
               y: int = 0,  # y draw offset
              ): PImage =
  new(result, free)
  init(result, filename, int16(x), int16(y))


# blit

method blit*(obj: PImage, x = 0'i16, y = 0'i16) =
  var dstRect: TRect
  dstRect.x = x + obj.x
  dstRect.y = y + obj.y
  do(blitSurface(obj.surface, nil, screen(), addr(dstRect)))

# get/set methods

method getRect*(obj: PImage): TRect =
  result.x = obj.x
  result.y = obj.y
  result.w = UInt16(obj.surface.w)
  result.h = UInt16(obj.surface.h)

# center offset

method centerOffset*(obj: PImage) {.inline.} =
  obj.x = -int16(obj.surface.w / 2)
  obj.y = -int16(obj.surface.h / 2)

method centerOffsetX*(obj: PImage) {.inline.} =
  obj.x = -int16(obj.surface.w / 2)

method centerOffsetY*(obj: PImage) {.inline.} =
  obj.y = -int16(obj.surface.h / 2)
