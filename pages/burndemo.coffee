# !TODO: Either use or remove iron-pages and page.js dependencies


Polymer
  is: "x-app"

  ready: ->
    @gestureActive = true
    @step = 0
    @steps = [
      {index: 0}
      {index: 1}
      {index: 2}
    ]
    console.log(document.querySelector('burn-Chart').step)

  properties:
    step: Number

  _listTap: ->
    @$.drawerPanel.closeDrawer()

  forward: ->
    if @step < @steps.length - 1 and @gestureActive
      @gestureActive = false
      @step++
      setTimeout(@enableGesture, 200)

  back: ->
    if @step > 0 and @gestureActive
      @gestureActive = false
      @step--
      setTimeout(@enableGesture, 200)

  enableGesture: ->
    document.querySelector('x-app').gestureActive = true
