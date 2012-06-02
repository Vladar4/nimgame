import
  sdl,
  common

type

  # Base class (virtual)
  PCollider* = ref TCollider
  TCollider* = object of TOBject
  
  # Box
  PBoxCollider* = ref TBoxCollider
  TBoxCollider* = object of TCollider
    left, right, top, bottom: int16

  # Circle
  PCircleCollider* = ref TCircleCollider
  TCircleCollider* = object of TCollider
    centerX, centerY: int16
    radius: UInt16

# BoxCollider

proc init*(obj: PBoxCollider, area: TRect) =
  obj.left = area.x
  obj.right = area.x + area.w
  obj.top = area.y
  obj.bottom = area.y + area.h

proc newBoxCollider*(area: TRect): PBoxCollider =
  new(result)
  init(result, area)

# CircleCollider

proc init*(obj: PCircleCollider, x: int16, y: int16, r: UInt16) =
  obj.centerX = x
  obj.centerY = y
  obj.radius = r
  
proc newCircleCollider*(area: TCircle): PCircleCollider =
  new(result)
  init(result, area.x, area.y, area.r)

# methods

# virtual methods
method x*(obj: PCollider): int16 {.inline.} = nil
method `x=`*(obj: PCollider, value: int16) {.inline.} = nil
method y*(obj: PCollider): int16 {.inline.} = nil
method `y=`*(obj: PCollider, value: int16) {.inline.} = nil


method collide*(a: PCollider, b: PCollider): bool = nil


# Box
method x*(obj: PBoxCollider): int16 {.inline.} = return obj.left
method `x=`*(obj: PBoxCollider, value: int16) {.inline.} =
  let dx = value - obj.left
  obj.left += dx
  obj.right += dx
method y*(obj: PBoxCollider): int16 {.inline.} = return obj.top
method `y=`*(obj: PBoxCollider, value: int16) {.inline.} =
  let dy = value - obj.top
  obj.top += dy
  obj.bottom += dy


# Box - Box
method collide(a: PBoxCollider, b: PBoxCollider): bool =
  if a.bottom <= b.top: return false
  if a.top >= b.bottom: return false
  if a.right <= b.left: return false
  if a.left >= b.right: return false
  return true


# Circle - Circle
method collide(a: PCircleCollider, b: PCircleCollider): bool =
  if distance((a.centerX, a.centerY), (b.centerX, b.centerY)).toInt < (a.radius + b.radius):
    return true
  return false

method x*(obj: PCircleCollider): int16 {.inline.} = return obj.centerX
method `x=`*(obj: PCircleCollider, value: int16) {.inline.} =
  obj.centerX = value
method y*(obj: PCircleCollider): int16 {.inline.} = return obj.centerY
method `y=`*(obj: PCircleCollider, value: int16) {.inline.} =
  obj.centerY = value


# Circle - Box
method collide(a: PCircleCollider, b: PBoxCollider): bool =
  var cx, cy: int16 # closest point
  # cx
  if a.centerX < b.left: cx = b.left
  elif a.centerX > b.right: cx = b.right
  else: cx = a.centerX
  # cy
  if a.centerY < b.top: cy = b.top
  elif a.centerY > b.bottom: cy = b.bottom
  else: cy = a.centerY
  # distance
  if distance((a.centerX, a.centerY), (cx, cy)).toInt < a.radius:
    return true
  return false


# Box - Circle
method collide(a: PBoxCollider, b: PCircleCollider): bool {.inline.} =
  return collide(b, a)
