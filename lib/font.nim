import
  sdl, sdl_ttf,
  common, screen, sprite

type

  # Base class (virtual)
  PFontObject* = ref TFontObject
  TFontObject* = object of TObject
  
  TTTFRenderMode* = enum solid, shaded, blended
  
  # TTF
  PTTFFont* = ref TTTFFont
  TTTFFont* = object of TFontObject
    fFont: PFont
    size*: int
    color*: TColor
    background*: TColor
    mode*: TTTFRenderMode
    utf8*: bool
  
  # Bitmap
  PBitmapFont* = ref TBitmapFont
  TBitmapFont* = object of TFontObject
    fFont: PSprite
    fColor: TColor
    fUseColor: bool


# methods

# virtual methods

method render*(obj: PFontObject, text: string): PSurface {.inline.} = nil
method free*(obj: PFontObject) = nil
method width*(obj: PFontObject, text: string): int {.inline.} = nil
method height*(obj: PFontObject): int {.inline.} = nil


# TTF Font

method width*(obj: PTTFFont, text: string): int {.inline.} =
  var w, h: cint
  if obj.utf8:
    do(sizeText(obj.fFont, text, w, h))
  else:
    do(sizeUTF8(obj.fFont, text, w, h))
  return w


method height*(obj: PTTFFont): int {.inline.} =
  return fontHeight(obj.fFont)


method render*(obj: PTTFFont, text: string): PSurface {.inline.} =
  if obj.utf8:
    case obj.mode:
    of solid: return do(renderUTF8_Solid(obj.fFont, text, obj.color))
    of shaded: return do(renderUTF8_Shaded(obj.fFont, text, obj.color, obj.background))
    of blended: return do(renderUTF8_Blended(obj.fFont, text, obj.color))
    else: return do(renderUTF8_Solid(obj.fFont, text, obj.color))
  else:
    case obj.mode:
    of solid: return do(renderText_Solid(obj.fFont, text, obj.color))
    of shaded: return do(renderText_Shaded(obj.fFont, text, obj.color, obj.background))
    of blended: return do(renderText_Blended(obj.fFont, text, obj.color))
    else: return do(renderText_Solid(obj.fFont, text, obj.color))


proc init*(obj: PTTFFont,
           filename: cstring,
           size: cint = 16,
           color: TColor = color(255, 255, 255),
           background: TColor = color(0, 0, 0),
           mode: TTTFRenderMode = solid,
           utf8: bool = true,
          ) =
  obj.fFont = do(openFont(filename, size))
  obj.size = size
  obj.color = color
  obj.background = background
  obj.mode = mode
  obj.utf8 = utf8


proc free*(obj: PTTFFont) =
  closeFont(obj.fFont)
  obj.fFont = nil


proc newTTFFont*(filename: cstring, # font filename
                 size: cint = 16, # font size
                 color: TColor = color(255, 255, 255), # font color
                 background: TColor = color(0, 0, 0), # background color (only for shaded render mode)
                 mode: TTTFRenderMode = solid, # TTF render mode (see sdl_ttf documentation)
                 utf8: bool = true, # use UTF8
                ): PTTFFont =
  new(result, free)
  init(result, filename, size, color, background, mode, utf8)


# Bitmap Font

method width*(obj: PBitmapFont, text: string): int {.inline.} =
  return obj.fFont.w * text.len


method height*(obj: PBitmapFont): int {.inline.} =
  return obj.fFont.h


method color*(obj: PBitmapFont): TColor {.inline.} =
  return obj.fColor

method `color=`*(obj: PBitmapFont, value: TColor) {.inline.} =
  if obj.fUseColor:
    obj.fColor = value
    obj.fFont.maskedFill(obj.fColor)


method render*(obj: PBitmapFont, text: string): PSurface {.inline.} =
  result = newSurface(obj.width(text), obj.height, true)
  var x: int16 = 0'i16
  for chr in text.items():
    let idx = ord(chr)
    obj.fFont.blitFrame(idx, result, x)
    x += obj.fFont.w


proc init*(obj: PBitmapFont,
           filename: cstring,
           w, h: UInt16,
          ) =
  obj.fUseColor = false
  obj.fFont = newSprite(filename, w=w, h=h)
  obj.color = color(0, 0, 0)


proc init*(obj: PBitmapFont,
           surface: PSurface,
           w, h: UInt16,
          ) =
  obj.fUseColor = false
  obj.fFont = newSprite(surface, w=w, h=h)
  obj.color = color(0, 0, 0)


proc init*(obj: PBitmapFont,
           filename: cstring,
           w, h: UInt16,
           color: TColor,
          ) =
  obj.fUseColor = true
  obj.fFont = newSprite(filename, w=w, h=h)
  obj.color = color


proc init*(obj: PBitmapFont,
           surface: PSurface,
           w, h: UInt16,
           color: TColor,
          ) =
  obj.fUseColor = true
  obj.fFont = newSprite(surface, w=w, h=h)
  obj.color = color


proc free*(obj: PBitmapFont) =
  obj.fFont.free()
  obj.fFont = nil


proc newBitmapFont*(filename: cstring, # font filename
                    w, h: int,         # char dimensions
                   ): PBitmapFont =
  new(result, free)
  init(result, filename, UInt16(w), UInt16(h))


proc newBitmapFont*(surface: PSurface, # font surface
                    w, h: int,         # char dimensions
                   ): PBitmapFont =
  new(result, free)
  init(result, surface, UInt16(w), UInt16(h))


proc newBitmapFont*(filename: cstring, # font filename
                    w, h: int,         # char dimensions
                    color: TColor,     # font color
                   ): PBitmapFont =
  new(result, free)
  init(result, filename, UInt16(w), UInt16(h), color)


proc newBitmapFont*(surface: PSurface, # font surface
                    w, h: int,         # char dimensions
                    color: TColor,     # font color
                   ): PBitmapFont =
  new(result, free)
  init(result, surface, UInt16(w), UInt16(h), color)


# multi-line render
proc render*(obj: PFontObject, text: openarray[string]): PSurface =
  # get max width
  var curw: int = 0
  var maxw: int = 0
  for i in 0..text.high:
    curw = obj.width(text[i])
    if curw > maxw: maxw = curw
  let height: int16 = obj.height.int16
  # create surface
  result = newSurface(maxw, height * text.len, true)
  # render
  var tmpLine: PSurface
  var dstRect: TRect
  for i in 0..text.high:
    tmpLine = render(obj, text[i])
    do(blitSurfaceAlpha(tmpLine, nil, result, addr(dstRect)))
    freeSurface(tmpLine)
    dstRect.y = dstRect.y + height
