import
  sdl, sdl_ttf,
  common, image

type

  TTextRenderMode* = enum solid, shaded, blended

  PText* = ref TText
  TText* = object of TImage
    fFont: PFont
    fSize: cint
    fColor: TColor
    fBackground: TColor
    fText: string
    fMode: TTextRenderMode
    fUTF8: bool


# redraw
method redraw(obj: PText) {.inline.} =
  if obj.fUTF8:
    case obj.fMode:
    of solid: obj.surface = do(renderUTF8_Solid(obj.fFont, obj.fText, obj.fColor))
    of shaded: obj.surface = do(renderUTF8_Shaded(obj.fFont, obj.fText, obj.fColor, obj.fBackground))
    of blended: obj.surface = do(renderUTF8_Blended(obj.fFont, obj.fText, obj.fColor))
    else: obj.surface = do(renderUTF8_Solid(obj.fFont, obj.fText, obj.fColor))
  else:
    case obj.fMode:
    of solid: obj.surface = do(renderText_Solid(obj.fFont, obj.fText, obj.fColor))
    of shaded: obj.surface = do(renderText_Shaded(obj.fFont, obj.fText, obj.fColor, obj.fBackground))
    of blended: obj.surface = do(renderText_Blended(obj.fFont, obj.fText, obj.fColor))
    else: obj.surface = do(renderText_Solid(obj.fFont, obj.fText, obj.fColor))


proc init*(obj: PText,
           filename: cstring,
           text: string = "text",
           size: cint = 16,
           color: TColor = color(255, 255, 255),
           background: TColor = color(0, 0, 0),
           mode: TTextRenderMode = solid,
           utf8: bool = true,
          ) =
  obj.fFont = do(openFont(filename, size))
  if text == "": obj.fText = " "
  else: obj.fText = text
  obj.fSize = size
  obj.fColor = color
  obj.fBackground = background
  obj.fMode = mode
  obj.fUTF8 = utf8  
  obj.redraw()


proc free*(obj: PText) =
  PImage(obj).free()
  closeFont(obj.fFont)
  obj.fFont = nil


proc newText*(filename: cstring, # font filename
              x: int = 0, # x draw offset
              y: int = 0, # y draw offset
              text: string = "text", # text to show
              size: cint = 16, # font size
              color: TColor = color(255, 255, 255), # font color
              background: TColor = color(0, 0, 0), # background color (only for shaded render mode)
              mode: TTextRenderMode = solid, # text render mode (see sdl_ttf documentation)
              utf8: bool = true, # use UTF8
             ): PText =
  new(result, free)
  init(PImage(result), nil, int16(x), int16(y))
  init(result, filename, text, size, color, background, mode, utf8)


# get/set methods

method size*(obj: PText): cint {.inline.} =
  return obj.fSize

method `size=`*(obj: PText, value: cint) {.inline.} =
  if value > 0:
    obj.fSize = value
    obj.redraw()


method color*(obj: PText): TColor {.inline.} =
  return obj.fColor

method `color=`*(obj: PText, value: TColor) {.inline.} =
  obj.fColor = value
  if obj.fMode == blended:
    obj.redraw()


method text*(obj: PText): string {.inline.} =
  return obj.fText

method `text=`*(obj: PText, value: string) {.inline.} =
  if value == "": obj.fText = " "
  else: obj.fText = value
  obj.redraw()


method mode*(obj: PText): TTextRenderMode {.inline.} =
  return obj.fMode

method `mode=`*(obj: PText, value: TTextRenderMode) {.inline} =
  obj.fMode = value
  obj.redraw()
