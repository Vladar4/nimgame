import
  entity, sprite, input, collider, mask

type
  PGUIButton* = ref TGUIButton
  TGUIButton* = object of TEntity
    fWasHovered, fWasPressed: bool


proc free*(obj: PGUIButton) =
  PEntity(obj).free()


proc newGUIButton*(graphic: PSprite,
                   x: float = 0.0, y: float = 0.0,
                   colliderType: TColliderType = CTBox): PGUIButton =
  new(result, free)
  init(PEntity(result), graphic, x, y)
  # set collider
  case colliderType:
  of CTPoint:
    result.collider = newPointCollider(result.xi, result.yi)
  of CTBox:
    result.collider = newBoxCollider(result.getRect())
  of CTCircle:
    result.collider = newCircleCollider(result.getCircle())
  of CTMask:
    result.collider = newMaskCollider(newMask(result.graphic.surface),
                                      result.xi, result.yi)
  else: nil
  # set variables
  result.fWasHovered = false
  result.fWasPressed = false


# Button frames in sprite must be in this order:
# 0 - default
# 1 - pressed
# 2 - hover
# 3 - hover pressed
proc updateFrame(obj: PGUIButton) =
  let spr = PSprite(obj.graphic)
  if obj.fWasHovered:
    if obj.fWasPressed:
      if spr.count > 3: spr.frame = 3
      elif spr.count > 1: spr.frame = 1
      else: spr.frame = 0
    else:
      if spr.count > 2: spr.frame = 2
      else: spr.frame = 0
  else:
    if obj.fWasPressed:
      if spr.count > 1: spr.frame = 1
      else: spr.frame = 0
    else:
      spr.frame = 0


proc updateButton*(obj: PGUIButton) =
  obj.updateEntity()
  if obj.collider.collide(mousePos()): # mouse over button
    if isButtonDown(1):
      obj.fWasPressed = true # button pressed
    elif isButtonUp(1):
      obj.fWasPressed = false # button released
    obj.fWasHovered = true
  else: # mouse not over button
    if obj.fWasPressed and isButtonUp(1): # button released
      obj.fWasPressed = false
    obj.fWasHovered = false
  obj.updateFrame()


method update*(obj: PGUIButton) {.inline.} =
  obj.updateButton()

