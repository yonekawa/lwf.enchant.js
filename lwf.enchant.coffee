LWF.useCanvasRenderer()

window.enchant.lwf =
  _env:
    defaultFrameRate: 60
    use3D: true

enchant.Event.LWF_LOADED = 'lwf_loaded'

enchant.lwf.requestAnimationFrame = ( ->
  window.requestAnimationFrame       or
  window.webkitRequestAnimationFrame or
  window.mozRequestAnimationFrame    or
  window.oRequestAnimationFrame      or
  window.msRequestAnimationFrame     or
  (callback, element) ->
    window.setTimeout(callback, 1000 / 60)
)()

currentTime = 0
fromTime = 0
enchant.lwf.calcTick = ->
  currentTime = Date.now() / 1000.0
  tick = currentTime - fromTime
  fromTime = currentTime
  tick

enchant.lwf.LWFEntity = enchant.Class.create(enchant.Entity,
  initialize: (lwfFileName, lwfPrefix, fps = enchant.lwf._env.defaultFrameRate) ->
    enchant.Entity.call(@)
    @fps = fps

    @_lwfFileName = lwfFileName
    @_lwfPrefix = lwfPrefix

    @_cache = LWF.ResourceCache.get()
    @_stage = document.createElement('canvas')
    @_stage.width = 0
    @_stage.height = 0
    @_stage.style.position = 'absolute'
    document.getElementById('enchant-stage').appendChild(@_stage)

    @_element = @stage

  load: ->
    @_cache.loadLWF(
      lwf    : @_lwfFileName
      prefix : @_lwfPrefix
      stage  : @_stage
      use3D  : enchant.lwf._env.use3D
      onload : (lwf) =>
        @lwf = lwf
        @lwf.setFrameRate(@fps)

        e = new enchant.Event(enchant.Event.LWF_LOADED)
        e.lwf = lwf
        @dispatchEvent(e)

        @main()
    )

  main: ->
    enchant.lwf.requestAnimationFrame.call(window, => @main())
    if @lwf?
      @lwf.exec(enchant.lwf.calcTick())
      @lwf.render()
)
