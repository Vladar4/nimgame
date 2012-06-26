import
  sdl, sdl_image, sdl_ttf, math

type
  TPoint* = tuple [x: int16, y: int16]
  TCircle* = tuple [x: int16, y: int16, r: UInt16]
  TVector* = tuple[x: float32, y: float32]


# USEREVENT codes
const UE_UPDATE_TIMER*: cint = 1
const UE_UPDATE_FPS*: cint = 2


# distance between two points
proc distance*(a: TPoint, b: TPoint): float32 =
  return sqrt(pow(toFloat(b.x) - toFloat(a.x), 2.0) + pow(toFloat(b.y) - toFloat(a.y), 2.0))

proc distance*(ax, ay: int16, b: TPoint): float32 {.inline.} =
  return distance((ax, ay), b)

proc distance*(a: TPoint, bx, by: int16): float32 {.inline.} =
  return distance(a, (bx, by))

proc distance*(ax, ay: int, b: TPoint): float32 {.inline.} =
  return distance((ax.int16, ay.int16), b)

proc distance*(a: TPoint, bx, by: int): float32 {.inline.} =
  return distance(a, (bx.int16, by.int16))


# angle direction from one to other point
proc direction*(a: TPoint, b: TPoint): float64 =
  let dx = float(a.x - b.x)
  let dy = float(a.y - b.y)
  return -(arctan2(dy, dx) / pi) * 180.0 + 90.0

proc direction*(ax, ay: int16, b: TPoint): float64 {.inline.} =
  return direction((ax, ay), b)

proc direction*(a: TPoint, bx, by: int16): float64 {.inline.} =
  return direction(a, (bx, by))

proc direction*(ax, ay: int, b: TPoint): float64 {.inline.} =
  return direction((ax.int16, ay.int16), b)

proc direction*(a: TPoint, bx, by: int): float64 {.inline.} =
  return direction(a, (bx.int16, by.int16))


# convert degrees to radians
template toRad*(a: float64): expr =
  (a * pi / 180.0)

# convert radians to degrees
template toDeg*(a: float64): expr =
  (a * 180.0 / pi)


# calculete vector
proc vector*(angle: float, size: float = 1.0): TVector {.inline.} =
  result.x = - size * cos(toRad(angle - 90.0))
  result.y = size * sin(toRad(angle - 90.0))

proc vectorX*(angle: float, size: float = 1.0): float32 {.inline.} =
  return - size * cos(toRad(angle - 90.0))

proc vectorY*(angle: float, size: float = 1.0): float32 {.inline.} =
  return size * sin(toRad(angle - 90.0))


# vector absolute size
proc absVector*(vector: TVector): float32 {.inline.} =
  return sqrt(vector.x * vector.x + vector.y * vector.y)

proc absVector*(x, y: float): float32 {.inline.} =
  return sqrt(x * x + y * y)


# create TColor
proc color*(r: int, g: int, b: int): TColor {.inline.} =
  result.r =toU8(r)
  result.g = toU8(g)
  result.b = toU8(b)


# SDL errors handling

proc do*(ret: int32): void =
  if ret != 0:
    echo(sdl.getError())
    sdl.quit()

proc do*(ret: TBool): void =
  if ret == sdlFALSE:
    echo(sdl.getError())
    sdl.quit()

proc do*(ret: PSurface): PSurface =
  if ret == nil:
    echo(sdl.getError())
    sdl.quit()
  return ret


# SDL TTF errors handling
proc do*(ret: PFont): PFont =
  if ret == nil:
    echo(sdl.getError())
    sdl.quit()
  return ret


# get screen surface
proc screen*(): PSurface {.inline.} =
  return do(getVideoSurface())


# create new surface
proc newSurface*(width, height: int, alpha: bool = false): PSurface =
  let fmt = screen().format
  let surface = do(
    createRGBSurface(
      screen().flags, width, height, fmt.bitsPerPixel,
      fmt.Rmask, fmt.Gmask, fmt.Bmask, fmt.Amask))
  if alpha:
    result = displayFormatAlpha(surface)
    do(result.fillRect(nil, mapRGBA(result.format, 0'i8, 0'i8, 0'i8, 0'i8)))
    freeSurface(surface)
  else:
    return surface


# Load image to the new surface
proc loadImage*(filename: cstring): PSurface =
  if filename != nil:
    if filename.len > 0:
      let surface: PSurface = do(imgLoad(filename))
      result = displayFormatAlpha(surface)
      freeSurface(surface)
  else:
    return nil


# blit surface preserving alpha channel
proc blitSurfaceAlpha*(src: PSurface, srcrect: PRect, dst: PSurface, dstrect: PRect): int =
  do(src.setAlpha(0, 255'i8))
  result = blitSurface(src, srcrect, dst, dstRect)
  do(src.setAlpha(SRCALPHA, 255'i8))
  do(src.setAlpha(SRCALPHA, 255'i8))
