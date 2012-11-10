import
  entity, image, sprite, collider, text, font, common, screen,
  gui_button

type
  PGUITextButton* = ref TGUITextButton
  TGUITextButton* = object of TGUIButton
    sprite*: PSprite
    text*: PText


proc createSprite(obj: PGUITextButton, graphic: PSprite) =
  if obj.graphic != nil:
    obj.graphic = nil
  
  # create button sprite
  let count = graphic.count /% 3
  let text_bg_count = int(obj.text.surface.w / graphic.w)
  let text_bg_w = text_bg_count * graphic.w
  let text_x_offset = text_bg_w /% 2
  let text_y_offset = graphic.h /% 2
  let sprite_w = graphic.w * 2 + text_bg_w
  let sprite_h = graphic.h * count

  var sprite = newSurface(sprite_w, sprite_h, alpha=true)
  for i in 0..count-1:
    # left
    graphic.blitFrame(i * 3, sprite, 0, graphic.h * i)
    # right
    graphic.blitFrame(i * 3 + 2, sprite, sprite_w - graphic.w, graphic.h * i)
    # center
    for j in 0..text_bg_count-1:
      graphic.blitFrame(i * 3 + 1, sprite,
                        graphic.w + graphic.w * j, graphic.h * i)
    # text
    if i %% 2 == 0: # for unpressed button
      obj.text.blit(sprite,
                    graphic.w + text_x_offset,
                    graphic.h * i + text_y_offset)
    else: # for pressed button draw text with small additional offset
      obj.text.blit(sprite,
                    graphic.w + text_x_offset + 1,
                    graphic.h * i + text_y_offset + 1)
    obj.graphic = newSprite(sprite, rows=count, cols=1)


proc init*(obj: PGUITextButton,
           graphic: PSprite, font: PFontObject, text: string) =
  obj.text = newText(font, 0, 0, text)
  obj.text.centerOffset()
  obj.createSprite(graphic)


proc free*(obj: PGUITextButton) =
  obj.text.free()
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

proc updateGUITextButton*(obj: PGUITextButton) =
  obj.updateGUIButton()


method update*(obj: PGUITextButton) {.inline.} =
  obj.updateGUITextButton()

