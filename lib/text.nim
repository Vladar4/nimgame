import
  sdl,
  common, image, font

type

  PText* = ref TText
  TText* = object of TImage
    fFont: PFontObject
    fText: string


# render
method render(obj: PText) {.inline.} =
  freeSurface(obj.surface)
  obj.surface = obj.fFont.render(obj.fText)


proc init*(obj: PText,
           font: PFontObject,
           text: string = "text",
          ) =
  obj.fFont = font
  if text == "": obj.fText = " "
  else: obj.fText = text
  obj.render()


proc free*(obj: PText) =
  obj.fFont.free()
  obj.fFont = nil
  PImage(obj).free()


proc newText*(font: PFontObject, # font
              x: int = 0, # x draw offset
              y: int = 0, # y draw offset
              text: string = "text", # text to show
             ): PText =
  new(result, free)
  init(PImage(result), "", int16(x), int16(y))
  init(result, font, text)


# get/set methods

method text*(obj: PText): string {.inline.} =
  return obj.fText

method `text=`*(obj: PText, value: string) {.inline.} =
  if value == "": obj.fText = " "
  else: obj.fText = value
  obj.render()

method font*(obj: PText): PFontObject {.inline.} =
  return obj.fFont
