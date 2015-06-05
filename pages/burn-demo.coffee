# !TODO: Either use or remove iron-pages and page.js dependencies

Polymer
  is: "burn-demo"

  ready: ->
    @gestureActive = true
    @step = 0
    @steps = [
      {index: 0}
      {index: 1}
      {index: 2}
    ]
#    console.log(document.querySelector('burn-chart').step)

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
    document.querySelector('burn-demo').gestureActive = true
