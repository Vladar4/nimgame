import
  sdl, sdl_image,
  common

type
  PPixelArray* = ref TPixelArray
  TPixelArray* = array[0..524288, uint32] # 524288 is 2560x2048 (QSXGA) surface size

  TScreen* = tuple[surface: PSurface,
                   width, height, flags, scale: int]

var
  scrBuffer: PSurface = nil
  scrScale: int = 1


proc screen*(): PSurface {.inline.} =
  ## Get screen surface.
  if scrScale == 1: return check(getVideoSurface())
  else: return scrBuffer


proc screenScale*(): int {.inline.} =
  ## Get screen scale rate.
  return scrScale


proc newSurface*(width, height: int, alpha: bool = false): PSurface =
  ## Create new surface with given ``width`` and ``height``.
  ##
  ## ``alpha`` = **true** to use alpha channel.
  let fmt = screen().format
  let surface = check(
    createRGBSurface(
      screen().flags, width, height, int(fmt.bitsPerPixel),
      fmt.Rmask, fmt.Gmask, fmt.Bmask, fmt.Amask))
  if alpha:
    result = displayFormatAlpha(surface)
    check(result.fillRect(nil, mapRGBA(result.format, 0, 0, 0, 0)))
    freeSurface(surface)
  else:
    return surface


template newSurface*(width, height: uint16, alpha: bool = false): PSurface =
  newSurface(int(width), int(height), alpha)


proc initScreenBuffer*(w, h, scale: int) =
  if scale > 1: scrBuffer = newSurface(w, h)
  scrScale = scale

proc freeScreenBuffer*() =
  if scrBuffer != nil: freeSurface(scrBuffer)


proc loadImage*(filename: cstring): PSurface =
  ## Load image from file to the new surface.
  if filename != nil:
    if filename.len > 0:
      let surface: PSurface = check(imgLoad(filename))
      result = displayFormatAlpha(surface)
      freeSurface(surface)
  else:
    return nil


proc blitSurfaceAlpha*(src: PSurface, srcrect: PRect,
                       dst: PSurface, dstrect: PRect): int =
  ## Blit surface preserving alpha channel.
  check(src.setAlpha(0, 255))
  result = blitSurface(src, srcrect, dst, dstRect)
  check(src.setAlpha(SRCALPHA, 255))

