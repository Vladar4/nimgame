import
  sdl, math,
  common, engine, image, collider

type

  PEntity* = ref TEntity
  TEntity* = object of TObject
    fX, fY: float
    fXi, fYi: int16
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
           x: float = 0.0,
           y: float = 0.0,
           layer: int = 0,
           kind: string = "",
           collider: PCollider = nil
          ) =
  obj.fX = x
  obj.fXi = x.round.int16
  obj.fY = y
  obj.fYi = y.round.int16
  obj.fLayer = layer
  obj.updateLayer = false
  obj.deleteEntity = false
  obj.kind = kind
  obj.graphic = graphic
  obj.collider = collider


proc newEntity*(graphic: PImage,
                x: float = 0.0,
                y: float = 0.0,
                layer: int = 0,
                kind: string = "",
                collider: PCollider = nil
               ): PEntity =
  new(result, free)
  init(result, graphic, x, y, layer, kind, collider)


# render

proc renderEntity*(obj: PEntity) =
  obj.graphic.blit(obj.fXi, obj.fYi)

method render*(obj: PEntity) {.inline.} =
  obj.renderEntity()


# get/set methods

method getRect*(obj: PEntity): TRect {.inline.} =
  result.x = obj.fXi + obj.graphic.x
  result.y = obj.fYi + obj.graphic.y
  result.w = UInt16(obj.graphic.surface.w)
  result.h = UInt16(obj.graphic.surface.h)


method getCircle*(obj: PEntity): TCircle {.inline.} =
  result.r = UInt16(min(obj.graphic.surface.w, obj.graphic.surface.h)/2)
  result.x = obj.fXi + result.r + obj.graphic.x
  result.y = obj.fYi + result.r + obj.graphic.y

# x
method x*(obj: PEntity): float {.inline.} =
  return obj.fX

method xi*(obj: PEntity): int {.inline.} =
  return obj.fXi

method `x=`*(obj: PEntity, value: int) {.inline.} =
  obj.fX = float(value)
  obj.fXi = int16(value)
  obj.collider.x = obj.fXi + obj.graphic.x

method `x=`*(obj: PEntity, value: float) {.inline.} =
  obj.fX = value
  obj.fXi = value.round.int16
  obj.collider.x = obj.fXi + obj.graphic.x


# y
method y*(obj: PEntity): float {.inline.} =
  return obj.fY

method yi*(obj: PEntity): int {.inline.} =
  return obj.fYi

method `y=`*(obj: PEntity, value: int) {.inline.} =
  obj.fY = float(value)
  obj.fYi = int16(value)
  obj.collider.y = obj.fY.round.int16 + obj.graphic.y

method `y=`*(obj: PEntity, value: float) {.inline.} =
  obj.fY = value
  obj.fYi = value.round.int16
  obj.collider.y = obj.fYi + obj.graphic.y


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


# update

proc updateEntity*(obj: PEntity) =
  obj.graphic.update()

method update*(obj: PEntity) {.inline.} =
  obj.updateEntity()
