import
  sdl,
  common, image, font

type

  PText* = ref TText
  TText* = object of TImage
    fFont: PFontObject
    fText: seq[string]


# render
method render(obj: PText) {.inline.} =
  freeSurface(obj.surface)
  obj.surface = obj.fFont.render(obj.fText)


proc init*(obj: PText,
           font: PFontObject,
           text: openarray[string],
          ) =
  obj.fFont = font
  if text.len == 0 or (text.len == 1 and text[0] == ""):
    obj.fText = @[" "]
  else:
    obj.fText = @[]
    obj.fText.add(text)
  obj.render()


proc free*(obj: PText) =
  obj.fFont.free()
  obj.fFont = nil
  PImage(obj).free()


proc newText*(font: PFontObject, # font
              x: int = 0, # x draw offset
              y: int = 0, # y draw offset
              text: openarray[string] = @["text"], # text to show
             ): PText =
  new(result, free)
  init(PImage(result), "", int16(x), int16(y))
  init(result, font, text)


# get/set methods

method text*(obj: PText): seq[string] {.inline.} =
  return obj.fText


method `text=`*(obj: PText, value: openarray[string]) {.inline.} =
  if value.len == 0 or (value.len == 1 and value[0] == ""):
    obj.fText = @[" "]
  else:
    obj.fText.setLen(0)
    # ERROR
    # next string frozes compiler for unknown reason
    #obj.fText.add(value)
    # so this is workaround
    for item in value: obj.fText.add(item)
  obj.render()


method line*(obj: PText, index: int = 0): string {.inline.} =
  return obj.fText[index]


method font*(obj: PText): PFontObject {.inline.} =
  return obj.fFont


template add*(obj: PText, value: string) =
  obj.fText.add(value)


template insert*(obj: PText, value: string, i: int = 0) =
  obj.fText.insert(value, i)
