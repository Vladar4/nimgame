import
  sdl,
  common

type

  PImage* = ref TImage
  TImage* = object of TObject
    x*, y*: int16
    surface*: PSurface
    visible*: bool
    deleteEntity*: bool


# TImage methods

proc init*(obj: PImage,
           filename: cstring,
           x: int16 = 0'i16,
           y: int16 = 0'i16,
          ) =
  # set position
  obj.x = x
  obj.y = y
  obj.visible = true
  obj.deleteEntity = false
  obj.surface = loadImage(filename)


proc init*(obj: PImage,
           surface: PSurface,
           x: int16 = 0'i16,
           y: int16 = 0'i16,
          ) =
  # set position
  obj.x = x
  obj.y = y
  obj.visible = true
  obj.deleteEntity = false
  obj.surface = surface


method free*(obj: PImage) =
  # ERROR
  #freeSurface(obj.surface)


proc newImage*(filename: cstring,
               x: int = 0,  # x draw offset
               y: int = 0,  # y draw offset
              ): PImage =
  new(result, free)
  init(result, filename, int16(x), int16(y))


proc newImage*(surface: PSurface,
               x: int = 0,  # x draw offset
               y: int = 0,  # y draw offset
              ): PImage =
  new(result, free)
  init(result, surface, int16(x), int16(y))


# blit

method blit*(obj: PImage, x = 0'i16, y = 0'i16) =
  if not obj.visible: return
  var dstRect: TRect
  dstRect.x = x + obj.x
  dstRect.y = y + obj.y
  do(blitSurface(obj.surface, nil, screen(), addr(dstRect)))


# update
method update*(obj: PImage) {.inline.} =
  nil


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


# visibility

method show*(obj: PImage) {.inline.} =
  obj.visible = true

method hide*(obj: PImage) {.inline.} =
  obj.visible = false
