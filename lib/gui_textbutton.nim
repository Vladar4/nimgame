import
  sdl, entity, image, sprite, collider, text, font, common, screen,
  gui_button

type
  PGUITextButton* = ref TGUITextButton
  TGUITextButton* = object of TGUIButton
    fSprite: PSprite
    fSurface: PSurface
    fText: PText


proc createSurface(obj: PGUITextButton, graphic: PSprite) =
  if obj.graphic != nil:
    obj.graphic = nil
  if obj.fSurface != nil:
    freeSurface(obj.fSurface)
    obj.fSurface = nil
  
  # create button sprite
  let count = graphic.count /% 3
  let text_bg_count = int(obj.fText.surface.w / graphic.w)
  let text_bg_w = text_bg_count * graphic.w
  let text_x_offset = text_bg_w /% 2
  let text_y_offset = graphic.h /% 2
  let sprite_w = graphic.w * 2 + text_bg_w
  let sprite_h = graphic.h * count

  obj.fSurface = newSurface(sprite_w, sprite_h, alpha=true)
  for i in 0..count-1:
    # left
    graphic.blitFrame(i * 3, obj.fSurface,
                      0, graphic.h * i)
    # right
    graphic.blitFrame(i * 3 + 2, obj.fSurface,
                      sprite_w - graphic.w, graphic.h * i)
    # center
    for j in 0..text_bg_count-1:
      graphic.blitFrame(i * 3 + 1, obj.fSurface,
                        graphic.w + graphic.w * j, graphic.h * i)
    # text
    if i %% 2 == 0: # for unpressed button
      obj.fText.blit(obj.fSurface,
                     graphic.w + text_x_offset,
                     graphic.h * i + text_y_offset)
    else: # for pressed button draw text with small additional offset
      obj.fText.blit(obj.fSurface,
                     graphic.w + text_x_offset + 1,
                     graphic.h * i + text_y_offset + 1)
    obj.graphic = newSprite(obj.fSurface, rows=count, cols=1)


proc init*(obj: PGUITextButton,
           graphic: PSprite, font: PFontObject, text: string) =
  obj.fSprite = graphic
  obj.fText = newText(font, 0, 0, text)
  obj.fText.centerOffset()
  obj.createSurface(graphic)


proc free*(obj: PGUITextButton) =
  obj.fText.free()
  PGUIButton(obj).free()


proc newGUITextButton*(graphic: PSprite, font: PFontObject, text: string,
                       x: float = 0.0, y: float = 0.0,
                       cmd: TCallback = nil, cmdObj: PObject = nil,
                       lockable: bool = false, locked: bool = false,
                       colliderType: TColliderType = CTBox): PGUITextButton =
  new(result, free)
  init(PEntity(result), nil, x, y)
  init(result, graphic, font, text)
  init(PGUIButton(result), cmd, cmdObj, lockable, locked, colliderType)


method text*(obj: PGUITextButton): string {.inline.} =
  return obj.fText.text[0]


method `text=`*(obj: PGUITextButton, value: string) {.inline.} =
  obj.fText.setText(value)
  obj.fText.centerOffset()
  obj.createSurface(obj.fSprite)


proc updateGUITextButton*(obj: PGUITextButton) =
  obj.updateGUIButton()


method update*(obj: PGUITextButton) {.inline.} =
  obj.updateGUITextButton()

