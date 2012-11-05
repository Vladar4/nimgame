import sdl

type

  TTimerCallbackProc = proc() {.closure.}

  PTimer* = ref TTimer
  TTimer* = object of TObject
    last, interval*: int
    callback*: TTimerCallbackProc
    

proc newTimer*(interval: int, callback: TTimerCallbackProc): PTimer =
  new(result)
  result.interval = interval
  result.callback = callback
  result.last = getTicks()


method update*(obj: PTimer) =
  let ticks = getTicks()
  if ticks - obj.last >= obj.interval:
    obj.last = ticks
    obj.callback()

