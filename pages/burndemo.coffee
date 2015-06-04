# !TODO: Either use or remove iron-pages and page.js dependencies

Polymer
  is: "x-app"

  ready: ->
    @step = 0
    @steps = [
      {index: 0}
      {index: 1}
      {index: 2}
    ]

  properties:
    _isMobile:
      type: Boolean
      observer: "_isMobileChanged"
    step: Number

  _listTap: ->
    @$.drawerPanel.closeDrawer()

  _isMobileChanged: (isMobile) ->
    @mainMode = (if isMobile then "seamed" else "cover")
    @drawerWidth = (if isMobile then "100%" else "50px")
    @toolbarClass = (if isMobile then "" else "tall")
    @updateStyles()

  forward: ->
    unless @step >= @steps.length - 1
      @step++

  back: ->
    unless @step is 0
      @step--