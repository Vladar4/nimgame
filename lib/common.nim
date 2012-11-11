import
  sdl, sdl_image, sdl_ttf, math

type
  TCallback* = proc(obj: PObject, sender: PObject) {.closure.}
  TPoint* = tuple [x: int, y: int]
  TCircle* = tuple [x: int, y: int, r: uint]
  TVector* = tuple[x: float, y: float]
  

# USEREVENT codes
const UE_UPDATE_TIMER*: cint = 1
const UE_UPDATE_INFO*: cint = 2


# distance between two points

proc distance*(a: TPoint, b: TPoint): float =
  ## **Return** distance between two points.
  return sqrt(pow(toFloat(b.x) - toFloat(a.x), 2.0) + pow(toFloat(b.y) - toFloat(a.y), 2.0))

template distance*(ax, ay: int, b: TPoint): float =
  distance((ax, ay), b)

template distance*(a: TPoint, bx, by: int): float =
  distance(a, (bx, by))

template distance*(ax, ay: int, b: TPoint): float =
  distance((ax, ay), b)

template distance*(a: TPoint, bx, by: int): float =
  distance(a, (bx, by))


# angle direction from one to other point

proc direction*(a: TPoint, b: TPoint): float =
  ## **Return** angle direction from one to other point.
  let dx = float(a.x - b.x)
  let dy = float(a.y - b.y)
  return -(arctan2(dy, dx) / pi) * 180.0 + 90.0

template direction*(ax, ay: int, b: TPoint): float =
  direction((ax, ay), b)

template direction*(a: TPoint, bx, by: int): float =
  direction(a, (bx, by))

template direction*(ax, ay: int, b: TPoint): float =
  direction((ax.int, ay.int), b)

template direction*(a: TPoint, bx, by: int): float =
  direction(a, (bx, by))


template toRad*(a: float): expr =
  ## Convert degrees to radians.
  (a * pi / 180.0)

template toDeg*(a: float): expr =
  ## Convert radians to degrees.
  (a * 180.0 / pi)


# calculete vector

proc vector*(angle: float, size: float = 1.0): TVector {.inline.} =
  # Calculate vector from given ``angle`` and ``size``.
  result.x = - size * cos(toRad(angle - 90.0))
  result.y = size * sin(toRad(angle - 90.0))

proc vectorX*(angle: float, size: float = 1.0): float {.inline.} =
  return - size * cos(toRad(angle - 90.0))

proc vectorY*(angle: float, size: float = 1.0): float {.inline.} =
  return size * sin(toRad(angle - 90.0))


# vector absolute size

proc absVector*(vector: TVector): float {.inline.} =
  ## Get absolute size of vector.
  return sqrt(vector.x * vector.x + vector.y * vector.y)

proc absVector*(x, y: float): float {.inline.} =
  return sqrt(x * x + y * y)


# color

proc color*(r: int, g: int, b: int): TColor {.inline.} =
  ## **Return** ``TColor`` created from given `r`, `g`, `b` components.
  result.r = Byte(r)
  result.g = Byte(g)
  result.b = Byte(b)


# SDL errors handling

proc check*(ret: int): void =
  ## SDL errors handling wrapper.
  if ret != 0:
    echo(sdl.getError())
    sdl.quit()

proc check*(ret: TBool): void =
  ## SDL errors handling wrapper.
  if ret == sdlFALSE:
    echo(sdl.getError())
    sdl.quit()

proc check*(ret: PSurface): PSurface =
  ## SDL errors handling wrapper.
  if ret == nil:
    echo(sdl.getError())
    sdl.quit()
  return ret


# SDL TTF errors handling

proc check*(ret: PFont): PFont =
  ## SDL TTF errors handling wrapper.
  if ret == nil:
    echo(sdl.getError())
    sdl.quit()
  return ret

