import
  sdl,
  common, engine, image, collider

type

  PEntity* = ref TEntity
  TEntity* = object of TObject
    fX, fY: int16
    fLayer*: int
    updateLayer*, deleteEntity*: bool
    kind*: string
    graphic*: PImage
    collider*: PCollider

# TEntity methods

proc free*(obj: PEntity) =
  obj.graphic.free()


proc init*(obj: PEntity,
           graphic: PImage,
           x: int16 = 0'i16,
           y: int16 = 0'i16,
           layer: int = 0,
           kind: string = "",
           collider: PCollider = nil
          ) =
  obj.fX = x
  obj.fY = y
  obj.fLayer = layer
  obj.updateLayer = false
  obj.deleteEntity = false
  obj.kind = kind
  obj.graphic = graphic
  obj.collider = collider


proc newEntity*(graphic: PImage,
                x: int = 0,
                y: int = 0,
                layer: int = 0,
                kind: string = "",
                collider: PCollider = nil
               ): PEntity =
  new(result, free)
  init(result, graphic, int16(x), int16(y), layer, kind, collider)

# render

proc renderEntity*(obj: PEntity) =
  obj.graphic.blit(obj.fX, obj.fY)

method render*(obj: PEntity) {.inline.} =
  obj.renderEntity()

# update

proc updateEntity*(obj: PEntity) =
  nil

method update*(obj: PEntity) {.inline.} =
  obj.updateEntity()

# get/set methods

method getRect*(obj: PEntity): TRect {.inline.} =
  result.x = obj.fX + obj.graphic.x
  result.y = obj.fY + obj.graphic.y
  result.w = UInt16(obj.graphic.surface.w)
  result.h = UInt16(obj.graphic.surface.h)


method getCircle*(obj: PEntity): TCircle {.inline.} =
  result.r = UInt16(min(obj.graphic.surface.w, obj.graphic.surface.h)/2)
  result.x = obj.fX + result.r + obj.graphic.x
  result.y = obj.fY + result.r + obj.graphic.y

# x
method x*(obj: PEntity): int {.inline.} =
  return obj.fX

method `x=`*(obj: PEntity, value: int) {.inline.} =
  obj.fX = int16(value)
  obj.collider.x = obj.fX + obj.graphic.x


# y
method y*(obj: PEntity): int {.inline.} =
  return obj.fY

method `y=`*(obj: PEntity, value: int) {.inline.} =
  obj.fY = int16(value)
  obj.collider.y = obj.fY + obj.graphic.y


# layer
method layer*(obj: PEntity): int {.inline.} =
  return obj.fLayer

method `layer=`*(obj: PEntity, value: int) {.inline.} =
  if obj.fLayer != value:
    obj.fLayer = value
    obj.updateLayer = true


# mark entity for deletion
method delete*(obj: PEntity) {.inline.} =
  obj.deleteEntity = true
