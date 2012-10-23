import
  sdl,
  unsigned,
  common, mask

type

  TColliderType* = enum CTPoint, CTBox, CTCircle, CTMask

  # Base class (virtual)
  PCollider* = ref TCollider
  TCollider* = object of TOBject
  
  # Point
  PPointCollider* = ref TPointCollider
  TPointCollider* = object of TCollider
    x, y: int
  
  # Box
  PBoxCollider* = ref TBoxCollider
  TBoxCollider* = object of TCollider
    left, right, top, bottom: int

  # Circle
  PCircleCollider* = ref TCircleCollider
  TCircleCollider* = object of TCollider
    centerX, centerY, radius: int
  
  # Mask
  PMaskCollider* = ref TMaskCollider
  TMaskCollider* = object of TCollider
    x, y: int
    mask*: PMask


# PointCollider

proc init*(obj: PPointCollider, x, y: int) =
  obj.x = x
  obj.y = y

proc newPointCollider*(pos: TPoint): PPointCollider =
  new(result)
  init(result, pos.x, pos.y)

proc newPointCollider*(x, y: int): PPointCollider =
  new(result)
  init(result, x, y)

# BoxCollider

proc init*(obj: PBoxCollider, x, y: int, w, h: uint) =
  obj.left = x
  obj.right = x + int(w)
  obj.top = y
  obj.bottom = y + int(h)

proc newBoxCollider*(area: TRect): PBoxCollider =
  new(result)
  init(result, area.x, area.y, area.w, area.h)

proc newBoxCollider*(x, y, w, h: int): PBoxCollider =
  new(result)
  init(result, x, y, uint(w), uint(h))


proc newBoxCollider*(pos: TPoint, w, h: int): PBoxCollider =
  new(result)
  init(result, pos.x, pos.y, uint(w), uint(h))


# CircleCollider

proc init*(obj: PCircleCollider, x, y: int, r: uint) =
  obj.centerX = x
  obj.centerY = y
  obj.radius = int(r)
  
proc newCircleCollider*(area: TCircle): PCircleCollider =
  new(result)
  init(result, area.x, area.y, area.r)

proc newCircleCollider*(x, y, r: int): PCircleCollider =
  new(result)
  init(result, x, y, uint(r))

proc newCircleCollider*(pos: TPoint, r: int): PCircleCollider =
  new(result)
  init(result, pos.x, pos.y, uint(r))


# MaskCollider

proc init*(obj: PMaskCollider, mask: PMask, x, y: int) =
  obj.mask = mask
  obj.x = x
  obj.y = y

proc newMaskCollider*(mask: PMask, x, y: int): PMaskCollider =
  new(result)
  init(result, mask, x, y)

proc newMaskCollider*(mask: PMask, pos: TPoint): PMaskCollider =
  new(result)
  init(result, mask, pos.x, pos.y)


# methods

# virtual methods
method x*(obj: PCollider): int {.inline.} = nil
method `x=`*(obj: PCollider, value: int) {.inline.} = nil
method y*(obj: PCollider): int {.inline.} = nil
method `y=`*(obj: PCollider, value: int) {.inline.} = nil

method collide*(a: PCollider, b: PCollider): bool = nil
method collide*(a: PCollider, b: TPoint): bool = nil
method collide*(a: TPoint, b: PCollider): bool = nil


# Point

method x*(obj: PPointCollider): int {.inline.} = return obj.x
method `x=`*(obj: PPointCollider, value: int) {.inline.} =
  obj.x = value
method y*(obj: PPointCollider): int {.inline.} = return obj.y
method `y=`*(obj: PPointCollider, value: int) {.inline.} =
  obj.y = value


# Box
method x*(obj: PBoxCollider): int {.inline.} = return obj.left
method `x=`*(obj: PBoxCollider, value: int) {.inline.} =
  let dx = value - obj.left
  obj.left += dx
  obj.right += dx
method y*(obj: PBoxCollider): int {.inline.} = return obj.top
method `y=`*(obj: PBoxCollider, value: int) {.inline.} =
  let dy = value - obj.top
  obj.top += dy
  obj.bottom += dy

# Circle

method x*(obj: PCircleCollider): int {.inline.} = return obj.centerX
method `x=`*(obj: PCircleCollider, value: int) {.inline.} =
  obj.centerX = value + obj.radius
method y*(obj: PCircleCollider): int {.inline.} = return obj.centerY
method `y=`*(obj: PCircleCollider, value: int) {.inline.} =
  obj.centerY = value + obj.radius

# Mask

method x*(obj: PMaskCollider): int {.inline.} = return obj.x
method `x=`*(obj: PMaskCollider, value: int) {.inline.} =
  obj.x = value
method y*(obj: PMaskCollider): int {.inline.} = return obj.y
method `y=`*(obj: PMaskCollider, value: int) {.inline.} =
  obj.y = value


# COLLIDE


# Point - Point

method collide*(a: PPointCollider, b: PPointCollider): bool =
  if (a.x == b.x) and (a.y == b.y):
    return true
  return false


method collide*(a: PPointCollider, b: TPoint): bool =
  if (a.x == b.x) and (a.y == b.y):
    return true
  return false


method collide*(a: TPoint, b: PPointCollider): bool {.inline.} =
  return collide(b, a)


# Box - Box
method collide*(a: PBoxCollider, b: PBoxCollider): bool =
  if a.bottom <= b.top: return false
  if a.top >= b.bottom: return false
  if a.right <= b.left: return false
  if a.left >= b.right: return false
  return true


# Circle - Circle
method collide*(a: PCircleCollider, b: PCircleCollider): bool =
  if distance((a.centerX, a.centerY), (b.centerX, b.centerY)).toInt < a.radius + b.radius:
    return true
  return false


# Mask - Mask
method collide*(a: PMaskCollider, b: PMaskCollider): bool =
  # Check bounding boxes
  var boxA, boxB: TRect
  boxA = a.mask.getRect()
  boxA.x = int16(boxA.x + a.x)
  boxA.y = int16(boxA.y + a.y)
  boxB = b.mask.getRect()
  boxB.x = int16(boxB.x + b.x)
  boxB.y = int16(boxB.y + b.y)
  if not collide(newBoxCollider(boxA), newBoxCollider(boxB)):
    return false
  # Check intersection rect
  var rectA, rectB: TRect
  var width, height: int
  if a.x > b.x:
    rectA.x = 0'i16
    rectB.x = int16(a.x - b.x)
    width = min(b.mask.w - int(rectB.x), a.mask.w)
  else:
    rectA.x = int16(b.x - a.x)
    rectB.x = 0'i16
    width = min(int16(a.mask.w) - rectA.x,  int16(b.mask.w))
  if a.y > b.y:
    rectA.y = 0'i16
    rectB.y = int16(a.y - b.y)
    height = min(int16(b.mask.h) - rectB.y,  int16(a.mask.h))
  else:
    rectA.y = int16(b.y - a.y)
    rectB.y = 0'i16
    height = min(int16(a.mask.h) - rectA.y,  int16(b.mask.h))
  rectA.w = uint16(width)
  rectB.w = uint16(width)
  rectA.h = uint16(height)
  rectB.h = uint16(height)
  # Per-pixel scan
  for y in 0..height-1:
    for x in 0..width-1:
      if a.mask.data[rectA.y + y][rectA.x + x] and
         b.mask.data[rectB.y + y][rectB.x + x]:
        return true
  return false
  

# Box - Point
method collide*(a: PBoxCollider, b: PPointCollider): bool =
  if (b.x < a.left) or (b.x >= a.right): return false
  if (b.y < a.top) or (b.y >= a.bottom): return false
  return true


method collide*(a: PBoxCollider, b: TPoint): bool =
  if (b.x < a.left) or (b.x >= a.right): return false
  if (b.y < a.top) or (b.y >= a.bottom): return false
  return true


# Point - Box
method collide*(a: PPointCollider, b: PBoxCollider): bool {.inline.} =
  return collide(b, a)

method collide*(a: TPoint, b: PBoxCollider): bool {.inline.} =
  return collide(b, a)


# Circle - Point
method collide*(a: PCircleCollider, b: PPointCollider): bool =
  if distance((b.x, b.y), (a.centerX, a.centerY)).toInt > a.radius: return false
  return true


method collide*(a: PCircleCollider, b: TPoint): bool =
  if distance((b.x, b.y), (a.centerX, a.centerY)).toInt > a.radius: return false
  return true


# Point - Circle
method collide*(a: PPointCollider, b: PCircleCollider): bool {.inline.} =
  return collide(b, a)


method collide*(a: TPoint, b: PCircleCollider): bool {.inline.} =
  return collide(b, a)


# Mask - Point
method collide*(a: PMaskCollider, b: PPointCollider): bool =
  var boxA: TRect
  boxA = a.mask.getRect()
  boxA.x = int16(boxA.x + a.x)
  boxA.y = int16(boxA.y + a.y)
  if not collide(newBoxCollider(boxA), b):
    return false
  if a.mask.data[b.y - boxA.y][b.x - boxA.x]:
    return true
  return false


method collide*(a: PMaskCollider, b: TPoint): bool =
  var boxA: TRect
  boxA = a.mask.getRect()
  boxA.x = int16(boxA.x + a.x)
  boxA.y = int16(boxA.y + a.y)
  if not collide(newBoxCollider(boxA), b):
    return false
  if a.mask.data[b.y - boxA.y][b.x - boxA.x]:
    return true
  return false


# Point - Mask
method collide*(a: PPointCollider, b: PMaskCollider): bool {.inline.} =
  return collide(b, a)


method collide*(a: TPoint, b: PMaskCollider): bool {.inline.} =
  return collide(b, a)


# Circle - Box
method collide*(a: PCircleCollider, b: PBoxCollider): bool =
  var cx, cy: int # closest point
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
method collide*(a: PBoxCollider, b: PCircleCollider): bool {.inline.} =
  return collide(b, a)


# Circle - Mask
method collide*(a: PCircleCollider, b: PMaskCollider): bool =
  # Check bounding boxes
  var boxB: TRect
  boxB = b.mask.getRect()
  boxB.x = int16(boxB.x + b.x)
  boxB.y = int16(boxB.y + b.y)
  if not collide(a, newBoxCollider(boxB)):
    return false
  # Check intersection rect
  var boxA, rectB: TRect
  var width, height: int
  boxA.x = int16(a.centerX - a.radius)
  boxA.y = int16(a.centerY - a.radius)
  boxA.w = uint16(a.centerX + a.radius)
  boxA.h = uint16(a.centerY + a.radius)
  if boxA.x > b.x:
    rectB.x = int16(boxA.x - b.x)
    width = min(int16(b.mask.w) - rectB.x, int16(boxA.w))
  else:
    rectB.x = 0'i16
    width = min(int(uint16(boxA.x) + boxA.w - uint16(b.x)), b.mask.w)
  if boxA.y > b.y:
    rectB.y = int16(boxA.y - b.y)
    height = min(b.mask.h - rectB.y, int(boxA.h))
  else:
    rectB.y = 0'i16
    height = min(int(uint16(boxA.x) + boxA.h) - b.y, b.mask.h)
  rectB.w = uint16(width)
  rectB.h = uint16(height)
  # Per-pixel scan
  let offsetX = boxB.x + rectB.x - a.centerX
  let offsetY = boxB.y + rectB.y - a.centerY
  for y in 0..height-1:
    for x in 0..width-1:
      let dx = abs(offsetX + x)
      let dy = abs(offsetY + y)
      if dx*dx + dy*dy <= a.radius * a.radius and
         b.mask.data[rectB.y + y][rectB.x + x]:
        return true
  return false


# Mask - Circle
method collide*(a: PMaskCollider, b: PCircleCollider): bool {.inline.} =
  return collide(b, a)

# Box - Mask
method collide*(a: PBoxCollider, b: PMaskCollider): bool =
  # Check bounding boxes
  var boxB: TRect
  boxB = b.mask.getRect()
  boxB.x = int16(boxB.x + b.x)
  boxB.y = int16(boxB.y + b.y)
  if not collide(a, newBoxCollider(boxB)):
    return false
  # Check intersection rect
  var rectB: TRect
  var width, height: int
  if a.left > b.x:
    rectB.x = int16(a.left - b.x)
    width = min(b.mask.w - rectB.x, a.right - a.left)
  else:
    rectB.x = 0'i16
    width = min(a.right - b.x, b.mask.w)
  if a.top > b.y:
    rectB.y = int16(a.top - b.y)
    height = min(b.mask.h - rectB.y, a.bottom - a.top)
  else:
    rectB.y = 0'i16
    height = min(a.bottom - b.y, b.mask.h)
  rectB.w = uint16(width)
  rectB.h = uint16(height)
  # Per-pixel scan
  for y in 0..height-1:
    for x in 0..width-1:
      if b.mask.data[rectB.y + y][rectB.x + x]:
        return true
  return false

# Mask - Box
method collide*(a: PMaskCollider, b: PBoxCollider): bool {.inline.} =
  return collide(b, a)
