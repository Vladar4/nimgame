import
  entity, sprite, input, collider, mask, common

type
  PGUIButton* = ref TGUIButton
  TGUIButton* = object of TEntity
    cmd*: TCallback
    cmdObj*: PObject
    lockable*, locked*: bool
    fWasHovered, fWasPressed: bool


proc free*(obj: PGUIButton) =
  PEntity(obj).free()


proc init*(obj: PGUIButton,
           cmd: TCallback, cmdObj: PObject = nil,
           lockable: bool = false, locked: bool = false,
           colliderType: TColliderType = CTBox) =
  # set collider
  case colliderType:
  of CTPoint:
    obj.collider = newPointCollider(obj.xi, obj.yi)
  of CTBox:
    obj.collider = newBoxCollider(obj.getRect())
  of CTCircle:
    obj.collider = newCircleCollider(obj.getCircle())
  of CTMask:
    obj.collider = newMaskCollider(newMask(obj.graphic.surface),
                                      obj.xi, obj.yi)
  else: nil
  # set variables
  obj.cmd = cmd
  obj.cmdObj = cmdObj
  obj.lockable = lockable
  obj.locked = locked
  obj.fWasHovered = false
  obj.fWasPressed = false



proc newGUIButton*(graphic: PSprite,
                   x: float = 0.0, y: float = 0.0,
                   cmd: TCallback = nil, cmdObj: PObject = nil,
                   lockable: bool = false, locked: bool = false,
                   colliderType: TColliderType = CTBox): PGUIButton =
  ## ``graphic``: sprite with button frames.
  ##
  ## ``x``, ``y``: button coordinates.
  ##
  ## ``cmd``: command callback (to call when button is pressed).
  ##
  ## ``cmdObj``: callback target object.
  ##
  ## ``lockable``: **true** if button is lockable.
  ##
  ## ``locked``: **true** to lock button by default
  ## (only if lockable is **true**)
  ##
  ## ``colliderType``: collider type (CTPoint, CTBox, CTCircle, CTMask)
  ##
  ## **Note**: button frames in sprite must be in this order:
  ## * 0 - default
  ## * 1 - pressed
  ## * 2 - hover
  ## * 3 - hover pressed
  new(result, free)
  init(PEntity(result), graphic, x, y)
  init(result, cmd, cmdObj, lockable, locked, colliderType)


proc updateFrame(obj: PGUIButton) =
  let spr = PSprite(obj.graphic)
  if obj.lockable and obj.locked: # locled button
    if obj.fWasHovered:
      if obj.fWasPressed: # hovered and pressed
        if spr.count > 2: spr.frame = 2
        else: spr.frame = 0
      else: # hovered
        if spr.count > 3: spr.frame = 3
        elif spr.count > 1: spr.frame = 1
        else: spr.frame = 0
    else: # not hovered
      if obj.fWasPressed:
        spr.frame = 0
      else:
        if spr.count > 1: spr.frame = 1
        else: spr.frame = 0
  else: # unlocked button
    if obj.fWasHovered:
      if obj.fWasPressed: # hovered and pressed
        if spr.count > 3: spr.frame = 3
        elif spr.count > 1: spr.frame = 1
        else: spr.frame = 0
      else: # hovered
        if spr.count > 2: spr.frame = 2
        else: spr.frame = 0
    else: # not hovered
      if obj.fWasPressed:
        if spr.count > 1: spr.frame = 1
        else: spr.frame = 0
      else:
        spr.frame = 0


proc updateGUIButton*(obj: PGUIButton) =
  obj.updateEntity()
  if obj.collider.collide(mousePos()): # mouse over button
    if isButtonDown(1):
      obj.fWasPressed = true # button pressed
    elif isButtonUp(1):
      if obj.fWasPressed:
        obj.fWasPressed = false # button released
        if obj.lockable:
          obj.locked = not obj.locked
        if obj.cmd != nil:
          obj.cmd(obj.cmdObj, obj)
      obj.fWasHovered = true
  else: # mouse not over button
    if obj.fWasPressed and isButtonUp(1): # button released
      obj.fWasPressed = false
    obj.fWasHovered = false
  obj.updateFrame()


method update*(obj: PGUIButton) {.inline.} =
  obj.updateGUIButton()

