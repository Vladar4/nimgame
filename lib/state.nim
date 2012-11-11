import
  entity, collider, sdl

type

  PState* = ref TState
  TState* = object of TObject
    fEntityList, fAddList: seq[PEntity]

# TState methods

method free*(obj: PState) =
  for entity in obj.fEntityList:
    entity.free()


proc init*(obj: PState) =
  obj.fEntityList = @[]
  obj.fAddList = @[]


proc newState*(): PState =
  new(result, free)
  init(result)

# Manage entities

method add*(obj: PState, entity: PEntity) {.inline.} =
  ## Add ``entity`` to state.
  obj.fAddList.add(entity)


method del*(obj: PState, entity: PEntity) =
  ## Delete ``entity`` from state.
  let index = obj.fEntityList.find(entity)
  if index <= 0:
    return
  obj.fEntityList.delete(index)


method clear*(obj: PState) =
  ## Delete ALL entities from state.
  while len(obj.fEntityList) > 0:
    obj.fEntityList.del(obj.fEntityList.high)


method count*(obj: PState): int {.inline.} =
  ## Get number of entities in state.
  return obj.fEntityList.len


method findKind*(obj: PState, kind: string): seq[PEntity] =
  ## Return sequence of entities of given ``kind``.
  result = @[]
  for i in 0..obj.fEntityList.high:
    if obj.fEntityList[i].kind == kind:
      result.add(obj.fEntityList[i])


method addToEntityList(obj: PState, entity: PEntity) =
  if obj.fEntityList.len > 0:
    for i in 0..obj.fEntityList.high:
      if entity.layer >= obj.fEntityList[i].layer:
        obj.fEntityList.insert(entity, i)
        return
  obj.fEntityList.add(entity)


method updateLayer(obj: PState, index: int): int =
  if index < 0:
    return
  let entity = obj.fEntityList[index]
  entity.updateLayer = false
  obj.fEntityList.delete(index)
  for i in 0..obj.fEntityList.high:
    if entity.layer >= obj.fEntityList[i].layer:
      obj.fEntityList.insert(entity, i)
      return i
  obj.fEntityList.add(entity)
  return obj.fEntityList.high


method updateEntityList(obj: PState) =
  var i: int = 0
  # add
  while obj.fAddList.len > 0:
    obj.addToEntityList(obj.fAddList.pop())
  var max = obj.fEntityList.high
  # delete
  i = 0
  while i <= max:
    if obj.fEntityList[i].deleteEntity or obj.fEntityList[i].graphic.deleteEntity:
      obj.fEntityList[i].deleteEntity = false
      obj.fEntityList[i].graphic.deleteEntity = false
      obj.fEntityList.delete(i)
      max -= 1
      continue
    i += 1
  # layers
  i = 0
  while i <= max:
    if obj.fEntityList[i].updateLayer:
      let new_i = obj.updateLayer(i)
      if new_i < i: i = new_i
    i += 1


# Collisions

method collideWith*(obj: PState, entity: PEntity, kind: string): PEntity =
  ## **Return** entity of ``kind``
  ## which collide with given ``entity``.
  let index = obj.fEntityList.find(entity)
  if index < 0 or entity.collider == nil:
    return nil
  for i in 0..obj.fEntityList.high:
    if i == index: continue
    if obj.fEntityList[i].kind == kind and obj.fEntityList[i].collider != nil:
      if entity.collider.collide(obj.fEntityList[i].collider):
        return obj.fEntityList[i]
  return nil


# entity collide with kinds
method collideWith*(obj: PState, entity: PEntity, kinds: varargs[string]): PEntity =
  ## **Return** entity of one of a ``kinds``
  ## which collide with given ``entity``.
  for kind in kinds.items():
    result = obj.collideWith(entity, kind)
    if result != nil:
      return result


method collideList*(obj: PState, kind1, kind2: string): seq[tuple[a, b: PEntity]] =
  ## **Return** sequence of pairs (``tuple[a, b: PEntity]``)
  ## of collided entities (``kind1`` collide with ``kind2``).
  result = @[]
  for i in 0..obj.fEntityList.high:
    if obj.fEntityList[i].kind == kind1 and obj.fEntityList[i].collider != nil:
      for j in 0..obj.fEntityList.high:
        if j == i: continue
        if obj.fEntityList[j].kind == kind2 and obj.fEntityList[j].collider != nil:
          if obj.fEntityList[i].collider.collide(obj.fEntityList[j].collider):
            result.add((obj.fEntityList[i], obj.fEntityList[j]))

# render

proc renderState*(obj: PState) =
  for entity in obj.fEntityList.items():
    entity.render()

method render*(obj: PState) {.inline.} =
  obj.renderState()

# update

proc updateState*(obj: PState) =
  obj.updateEntityList()
  for entity in obj.fEntityList.items():
    entity.update()

method update*(obj: PState) {.inline.} =
  obj.updateState()

