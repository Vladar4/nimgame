import
  sdl,
  common

type

  # Base class (virtual)
  PCollider* = ref TCollider
  TCollider* = object of TOBject
  
  # Point
  PPointCollider* = ref TPointCollider
  TPointCollider* = object of TCollider
    x, y: int16
  
  # Box
  PBoxCollider* = ref TBoxCollider
  TBoxCollider* = object of TCollider
    left, right, top, bottom: int16

  # Circle
  PCircleCollider* = ref TCircleCollider
  TCircleCollider* = object of TCollider
    centerX, centerY: int16
    radius: UInt16

# PointCollider

proc init*(obj: PPointCollider, x, y: int16) =
  obj.x = x
  obj.y = y

proc newPointCollider*(pos: TPoint): PPointCollider =
  new(result)
  init(result, pos.x, pos.y)

proc newPointCollider*(x, y: int): PPointCollider =
  new(result)
  init(result, int16(x), int16(y))

# BoxCollider

proc init*(obj: PBoxCollider, x, y: int16, w, h: UInt16) =
  obj.left = x
  obj.right = x + w
  obj.top = y
  obj.bottom = y + h

proc newBoxCollider*(area: TRect): PBoxCollider =
  new(result)
  init(result, area.x, area.y, area.w, area.h)

proc newBoxCollider*(x, y, w, h: int): PBoxCollider =
  new(result)
  init(result, int16(x), int16(y), UInt16(w), UInt16(h))

# CircleCollider

proc init*(obj: PCircleCollider, x, y: int16, r: UInt16) =
  obj.centerX = x
  obj.centerY = y
  obj.radius = r
  
proc newCircleCollider*(area: TCircle): PCircleCollider =
  new(result)
  init(result, area.x, area.y, area.r)

proc newCircleCollider*(x, y, r: int): PCircleCollider =
  new(result)
  init(result, int16(x), int16(y), UInt16(r))

# methods

# virtual methods
method x*(obj: PCollider): int16 {.inline.} = nil
method `x=`*(obj: PCollider, value: int16) {.inline.} = nil
method y*(obj: PCollider): int16 {.inline.} = nil
method `y=`*(obj: PCollider, value: int16) {.inline.} = nil

method collide*(a: PCollider, b: PCollider): bool = nil


# Point

method x*(obj: PPointCollider): int16 {.inline.} = return obj.x
method `x=`*(obj: PPointCollider, value: int16) {.inline.} =
  obj.x = value
method y*(obj: PPointCollider): int16 {.inline.} = return obj.y
method `y=`*(obj: PPointCollider, value: int16) {.inline.} =
  obj.y = value


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

# Circle

method x*(obj: PCircleCollider): int16 {.inline.} = return obj.centerX
method `x=`*(obj: PCircleCollider, value: int16) {.inline.} =
  obj.centerX = value
method y*(obj: PCircleCollider): int16 {.inline.} = return obj.centerY
method `y=`*(obj: PCircleCollider, value: int16) {.inline.} =
  obj.centerY = value



# COLLIDE


# Point - Point

method collide(a: PPointCollider, b: PPointCollider): bool =
  if (a.x == b.x) and (a.y == b.y):
    return true
  return false


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


# Point - Box
method collide(a: PPointCollider, b: PBoxCollider): bool =
  if (a.x < b.left) or (a.x > b.right): return false
  if (a.y < b.top) or (a.y > b.bottom): return false
  return true


# Box - Point
method collide(a: PBoxCollider, b: PPointCollider): bool {.inline.} =
  return collide(b, a)


# Point - Circle
method collide(a: PPointCollider, b: PCircleCollider): bool =
  if UInt16(distance((a.x, a.y), (b.centerX, b.centerY))) > b.radius: return false
  return true


# Circle - Point
method collide(a: PCircleCollider, b: PPointCollider): bool {.inline.} =
  return collide(b, a)


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
