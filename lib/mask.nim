import
  sdl, sdl_image,
  unsigned,
  common, screen

type
  PMask* = ref TMask
  TMask* = object of TObject
    x*, y*: int
    w*, h*: int
    data*: seq[seq[bool]]


proc setMask*(obj: PMask,
              surface: PSurface) =
  check(lockSurface(surface))
  let amask = uint32(surface.format.Amask)
  let ashift = uint32(surface.format.Ashift)
  let aloss = uint32(surface.format.Aloss)
  let pixels: PPixelArray = cast[PPixelArray](surface.pixels)
  var offset: int
  var pixel, temp: uint32
  var alpha: int
  obj.data = @[]
  for y in 0..surface.h-1:
    obj.data.add(@[])
    #write(stdout, "\n")  # DEBUG: Uncomment to output mask
    for x in 0..surface.w-1:
      offset = y * surface.w + x
      pixel = pixels[offset]
      temp = pixel and amask
      temp = temp shr ashift
      alpha = int(temp shl aloss)
      if alpha < 127:
        obj.data[obj.data.high].add(false)
        #write(stdout, " ") # DEBUG: Uncomment to output mask
      else:
        obj.data[obj.data.high].add(true)
        #write(stdout, "X")  # DEBUG: Uncomment to output mask
  unlockSurface(surface)


proc init*(obj: PMask, filename: cstring, x: int = 0, y: int = 0) =
  obj.x = x
  obj.y = y
  if filename != nil:
    let surface: PSurface = check(imgLoad(filename))
    obj.w = surface.w
    obj.h = surface.h
    obj.setMask(surface)
    freeSurface(surface)


proc init*(obj: PMask, surface: PSurface, x: int = 0, y: int = 0) =
  obj.x = x
  obj.y = y
  obj.w = surface.w
  obj.h = surface.h
  obj.setMask(surface)


proc newMask*(filename: cstring, x: int = 0, y: int = 0): PMask =
  new(result)
  init(result, filename, x, y)



proc newMask*(surface: PSurface, x: int = 0, y: int = 0): PMask =
  new(result)
  init(result, surface, x, y)


method getRect*(obj: PMask): TRect =
  result.x = int16(obj.x)
  result.y = int16(obj.y)
  result.w = uint16(obj.w)
  result.h = uint16(obj.h)
