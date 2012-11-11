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
  # check for empty lines
  for i in 0..obj.fText.high:
    if obj.fText[i] == "":
      obj.fText[i] = " "
  # render
  freeSurface(obj.surface)
  obj.surface = obj.fFont.render(obj.fText)


proc init*(obj: PText,
           font: PFontObject,
           text: varargs[string],
          ) =
  obj.fFont = font
  if text.len == 0:
    obj.fText = @[" "]
  else:
    obj.fText = @[]
    obj.fText.add(text)
  obj.render()


proc free*(obj: PText) =
  PImage(obj).free()


proc newText*(font: PFontObject, # font
              x: int = 0, # x draw offset
              y: int = 0, # y draw offset
              text: varargs[string] = @["text"], # text
             ): PText =
  ## ``font``: font object to write text with.
  ##
  ## ``x``, ``y``: draw offset.
  ##
  ## ``text``: text lines.
  new(result, free)
  init(PImage(result), "", int16(x), int16(y))
  init(result, font, text)


# get/set methods

method text*(obj: PText): seq[string] {.inline.} =
  ## Get text lines.
  return obj.fText


method `text=`*(obj: PText, value: varargs[string]) =
  ## Set text lines.
  if value.len == 0:
    obj.fText = @[" "]
  else:
    obj.fText.setLen(0)
    for s in value.items:
      obj.fText.add(s)
  obj.render()

method setText*(obj: PText, text: varargs[string]) =
  ## Set text lines.
  obj.fText.setLen(0)
  if text.len == 0:
    obj.fText.add(" ")
  else:
    for line in text.items:
      obj.fText.add(line)
  obj.render()


method line*(obj: PText, line: int = 0): string {.inline.} =
  ## Get specific ``line`` of text.
  return obj.fText[line]


method append*(obj: PText, line: int = 0, value: string) =
  ## Append to specific ``line`` of text.
  obj.fText[line].add(value)
  obj.render()


method font*(obj: PText): PFontObject {.inline.} =
  ## Get text font object.
  return obj.fFont


method add*(obj: PText, value: string) =
  ## Add new line.
  obj.fText.add(value)
  obj.render()


method insert*(obj: PText, value: string, i: int = 0) =
  ## Insert new line in text.
  ##
  ## ``i``: index of inserted line.
  obj.fText.insert(value, i)
  obj.render()

