import
  sdl, sdl_image,
  common

type
  PPixelArray* = ref TPixelArray
  TPixelArray* = array[0..524288, UInt32] # 524288 is 2560x2048 (QSXGA) surface size

var
  scrBuffer: PSurface = nil
  scrScale: int32 = 1


# get screen surface
proc screen*(): PSurface {.inline.} =
  if scrScale == 1: return do(getVideoSurface())
  else: return scrBuffer


# get screen scale
proc screenScale*(): int {.inline.} =
  return scrScale


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


# screen buffer
proc initScreenBuffer*(w, h, scale: int) =
  if scale > 1: scrBuffer = newSurface(w, h)
  scrScale = scale

proc freeScreenBuffer*() =
  if scrBuffer != nil: freeSurface(scrBuffer)


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
