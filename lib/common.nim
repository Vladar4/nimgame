import
  sdl, sdl_ttf, math

type
  TPoint* = tuple [x: int16, y: int16]
  TCircle* = tuple [x: int16, y: int16, r: UInt16]


# USEREVENT codes
const UE_UPDATE_TIMER*: cint = 1
const UE_UPDATE_FPS*: cint = 2


# distance between two points
proc distance*(a: TPoint, b: TPoint): float32 =
  return sqrt(pow(toFloat(b.x) - toFloat(a.x), 2.0) + pow(toFloat(b.y) - toFloat(a.y), 2.0))


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
proc newSurface*(width, height: int): PSurface {.inline.} =
  let scr = screen()
  return do(
    createRGBSurface(
      scr.flags, width, height, scr.format.bitsPerPixel,
      scr.format.rMask, scr.format.gMask, scr.format.bMask, scr.format.aMask))
