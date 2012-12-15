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

# TODO: The plugin does not work with enchant.js v0.6.
CanvasGroup = enchant.CanvasLayer ? enchant.CanvasGroup
enchant.lwf.LWFEntity = enchant.Class.create(CanvasGroup,
  initialize: (lwfFileName, lwfPrefix) ->
    CanvasGroup.call(@)

    @_lwfFileName = lwfFileName
    @_lwfPrefix = lwfPrefix

    @_cache = LWF.ResourceCache.get()
    if enchant.ENV.TOUCH_ENABLED
      @_element.addEventListener('touchstart', ((e) => @onTouchStart(e)), false)
      @_element.addEventListener('touchmove',  ((e) => @onTouchMove(e)),  false)
      @_element.addEventListener('touchend',   ((e) => @onTouchEnd(e)),   false)
    else
      @_element.addEventListener('mousedown',  ((e) => @onTouchStart(e)), false)
      @_element.addEventListener('mousemove',  ((e) => @onTouchMove(e)),  false)
      @_element.addEventListener('mouseup',    ((e) => @onTouchEnd(e)),   false)

    # @addEventListener(enchant.Event.ADDED,   => @parentNode._element.appendChild(@_element))
    # @addEventListener(enchant.Event.REMOVED, => @parentNode._element.removeChild(@_element))

  load: ->
    @_cache.loadLWF(
      lwf    : @_lwfFileName
      prefix : @_lwfPrefix
      stage  : @_element
      use3D  : enchant.lwf._env.use3D
      onload : (lwf) =>
        @lwf = lwf
        @lwf.setFrameRate(enchant.lwf._env.frameRate)

        e = new enchant.Event(enchant.Event.LWF_LOADED)
        e.lwf = lwf

        @_element.width = lwf.width
        @_element.height = lwf.height
        @_element.style.width = "#{lwf.width}px"
        @_element.style.height = "#{lwf.height}px"
        @dispatchEvent(e)

        @main()
    )

  main: ->
    enchant.lwf.requestAnimationFrame.call(window, => @main())
    if @lwf?
      @lwf.exec(enchant.lwf.calcTick())
      @lwf.render()

  onTouchStart: (e) ->
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - @_element.offsetLeft
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - @_element.offsetTop

    if @lwf?
      @lwf.inputPoint(x, y)
      @lwf.inputPress()

    e = new enchant.Event(enchant.Event.TOUCH_START)
    e._initPosition(x, y)
    @dispatchEvent(e)

  onTouchMove: (e) ->
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - @_element.offsetLeft
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - @_element.offsetTop
    @lwf.inputPoint(x, y) if @lwf?

    e = new enchant.Event(enchant.Event.TOUCH_MOVE)
    e._initPosition(x, y)
    @dispatchEvent(e)

  onTouchEnd: (e) ->
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - @_element.offsetLeft
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - @_element.offsetTop
    @lwf.inputRelease() if @lwf?

    e = new enchant.Event(enchant.Event.TOUCH_END)
    e._initPosition(x, y)
    @dispatchEvent(e)
)
