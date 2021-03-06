###
 * @fileOverview
 * lwd.enchant.js
 * @version 0.1.0
 * @require enchant.js v0.5.2.
 * @author Kenichi Yonekawa
 *
 * @description
 *   Plugin for using LWF(https://github.com/gree/lwf) with enchant.js.
 *
###

LWF.useCanvasRenderer()

window.enchant.lwf =
  _env:
    frameRate: 60
    scale: 1
    use3D: true

enchant.Event.LWF_LOADED = 'lwf_loaded'

enchant.lwf.requestAnimationFrame = ( ->
  window.requestAnimationFrame       or
  window.webkitRequestAnimationFrame or
  window.mozRequestAnimationFrame    or
  window.oRequestAnimationFrame      or
  window.msRequestAnimationFrame     or
  (callback, element) ->
    window.setTimeout(callback, 1000 / window.enchant.lwf._env.frameRate)
)()

currentTime = 0
fromTime = 0
enchant.lwf.calcTick = ->
  currentTime = Date.now() / 1000.0
  tick = currentTime - fromTime
  fromTime = currentTime
  tick

enchant.lwf.entities = []
main = ->
  enchant.lwf.requestAnimationFrame.call(window, main)
  tick = enchant.lwf.calcTick()
  for entity in enchant.lwf.entities
    entity.lwf.exec(tick)
    entity.lwf.render()
main()

# TODO: The plugin does not work with enchant.js v0.6.
enchant.lwf.LWFEntity = enchant.Class.create(enchant.Entity,
  initialize: (lwfFileName, lwfPrefix) ->
    enchant.Entity.call(@)

    @_lwfFileName = lwfFileName
    @_lwfPrefix = lwfPrefix

    @_cache = LWF.ResourceCache.get()

    CanvasGroup = enchant.CanvasLayer ? enchant.CanvasGroup
    @_canvas = new CanvasGroup()
    @_element = @_canvas._element

    @_directionX = 1
    @_directionY = 1

    if enchant.ENV.TOUCH_ENABLED
      @_element.addEventListener('touchstart', ((e) => @onTouchStart(e)), false)
      @_element.addEventListener('touchmove',  ((e) => @onTouchMove(e)),  false)
      @_element.addEventListener('touchend',   ((e) => @onTouchEnd(e)),   false)
    else
      @_element.addEventListener('mousedown',  ((e) => @onTouchStart(e)), false)
      @_element.addEventListener('mousemove',  ((e) => @onTouchMove(e)),  false)
      @_element.addEventListener('mouseup',    ((e) => @onTouchEnd(e)),   false)

  load: (callback = null) ->
    @_cache.loadLWF(
      lwf    : @_lwfFileName
      prefix : @_lwfPrefix
      stage  : @_element
      use3D  : enchant.lwf._env.use3D
      onload : (lwf) =>
        @lwf = lwf
        @lwf.scaleForWidth(Math.round(lwf.width / enchant.lwf._env.scale))
        @lwf.setFrameRate(enchant.lwf._env.frameRate)

        e = new enchant.Event(enchant.Event.LWF_LOADED)
        e.lwf = lwf

        @_element.width = lwf.width
        @_element.height = lwf.height
        @_element.style.width = "#{lwf.width}px"
        @_element.style.height = "#{lwf.height}px"

        callback?(lwf)
        @dispatchEvent(e)

        @addEventListener(enchant.Event.REMOVED_FROM_SCENE, =>
          index = enchant.lwf.entities.indexOf(@)
          enchant.lwf.entities.splice(index, 1) unless index is -1
        )
        @addEventListener(enchant.Event.ADDED_FROM_SCENE, =>
          enchant.lwf.entities.unshift(@) if enchant.lwf.entities.indexOf(@) is -1
        )
        @dispatchEvent(enchant.Event.ADDED_FROM_SCENE)
    )

  width:
    get: -> @_element.width / enchant.lwf._env.scale

  height:
    get: -> @_element.height / enchant.lwf._env.scale

  x:
    get: ->
      @_x
    set: (x) ->
      @_x = x
      @_element.style.left = "#{x}px"

  y:
    get: ->
      @_y
    set: (y) ->
      @_y = y
      @_element.style.top = "#{y}px"

  reverseX: ->
    @_directionX *= -1
    @_element.style.webkitTransform = "translateZ(0) scale(#{@_directionX}, #{@_directionY})"

  reverseY: ->
    @_directionY *= -1
    @_element.style.webkitTransform = "translateZ(0) scale(#{@_directionX}, #{@_directionY})"

  onTouchStart: (e) ->
    clientX = if e.clientX? then e.clientX else e.touches[0].clientX
    clientY = if e.clientY? then e.clientY else e.touches[0].clientY
    x = clientX + document.body.scrollLeft + document.documentElement.scrollLeft - @_element.offsetLeft
    y = clientY + document.body.scrollTop + document.documentElement.scrollTop - @_element.offsetTop

    if @lwf?
      @lwf.inputPoint(x, y)
      @lwf.inputPress()

    e = new enchant.Event(enchant.Event.TOUCH_START)
    e._initPosition(x, y)
    @dispatchEvent(e)

  onTouchMove: (e) ->
    clientX = if e.clientX? then e.clientX else e.touches[0].clientX
    clientY = if e.clientY? then e.clientY else e.touches[0].clientY
    x = clientX + document.body.scrollLeft + document.documentElement.scrollLeft - @_element.offsetLeft
    y = clientY + document.body.scrollTop + document.documentElement.scrollTop - @_element.offsetTop
    @lwf.inputPoint(x, y) if @lwf?

    e = new enchant.Event(enchant.Event.TOUCH_MOVE)
    e._initPosition(x, y)
    @dispatchEvent(e)

  onTouchEnd: (e) ->
    @lwf.inputRelease() if @lwf?

    e = new enchant.Event(enchant.Event.TOUCH_END)
    @dispatchEvent(e)
)
