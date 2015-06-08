delay = (m, f) ->
  setTimeout(f, m)

class Tag
  constructor: (@tagType, @tagAttributes, @parent = null, @tagText = null) ->

    unless this instanceof Tag
      return new Tag(@tagType, @tagAttributes, @parent, @tagText)

    @children = []

    if @parent?
      if @parent.tagText?
        throw new Error('Text and chilren on same element unsupported at this time')
      else
        @parent.children.push(this)
        @level = @parent.level + 1
    else
      @level = 0

  @camelToDash: (str) ->
    return str.replace(/\W+/g, "-").replace(/([a-z\d])([A-Z])/g, "$1-$2").toLowerCase()

  tagOpenString: ->
    s = "<#{@tagType}"
    for key, value of @tagAttributes
      dashedKey = Tag.camelToDash(key)
      s += " #{dashedKey}=\"#{value.toString()}\""
    s += '>'
    return s

  tagCloseString: ->
    return "</#{@tagType}>"

  toString: ->
    s = Array(@level + 1).join('  ') + @tagOpenString()
    if @tagText?
      s += @tagText.toString()
    else if @children.length > 0
      for c in @children
        s += '\n' + c.toString()
      s += '\n' + Array(@level + 1).join('  ')
    s += @tagCloseString()
    return s

class Line extends Tag
  Line.defaultAttributes =
    stroke: 'black'
    "stroke-width": 1
    "stroke-linecap": "round"
    "stroke-linejoin": "round"

  constructor: (x1, y1, x2, y2, @tagAttributes = {}, @parent = null) ->
    @tagAttributes.x1 = "#{x1}%"
    @tagAttributes.y1 = "#{y1}%"
    @tagAttributes.x2 = "#{x2}%"
    @tagAttributes.y2 = "#{y2}%"
    if Line.defaultAttributes?
      for key, value of Line.defaultAttributes
        @tagAttributes[key] = value
    return super('line', @tagAttributes, @parent)

  @setDefaultAttributes: (newOrOverideAttributes) ->
    @defaultAttributes[key] = value for key, value of newOrOverideAttributes

class LineSeries extends Tag
  constructor: (x0, y0, periodWidth, series, @tagAttributes = {}, @parent = null) ->
    unless series?
      return
    lineSeries = Tag('g', @tagAttributes, @parent)
    x = x0
    if series?
      i = 0
      while !series[i]? and i < series.length
        x += periodWidth
        i++
      x1 = x
      y1 = y0 - series[i]
      i++
      x += periodWidth
      while i < series.length
        point = series[i]

        if point?
          x2 = x
          y2 = y0 - point
          line = Line(x1, y1, x2, y2, null, lineSeries)
          x1 = x2
          y1 = y2

        x += periodWidth
        i++

    return lineSeries

class Rect extends Tag
  constructor: (x, y, width, height, @tagAttributes = {}, @parent = null) ->
    @tagAttributes.x = "#{x}%"
    @tagAttributes.y = "#{y}%"
    @tagAttributes.width = "#{width}%"
    @tagAttributes.height = "#{height}%"
    return super('rect', @tagAttributes, @parent)

rootAttributes =
  id: 'burn-chart-svg'
  xmlns: "http://www.w3.org/2000/svg"
  width: '100%'
  height: '100%'
  'xmlns:xlink': "http://www.w3.org/1999/xlink"
  preserveAspectRatio: "none"

Polymer(
  is: "burn-chart"

  properties:
    ###
    periods: Number
    burnSeries: Array
    scopeSeries: Array
    linearProjection: Array
    forecastProjections: Array  # Actually and Array of Arrays but I'll add an entire row at a time
    histogram: Array
    ###
    config:
      type: Object
      observer: 'gotNewConfig'

  created: ->


  gotNewConfig: (newValue, @oldConfig) ->
    window.burnChartConfig = newValue
    attributes = rootAttributes  # !TODO: Need to copy this. Need to move rootAttributes inside to @rootAttribtues
    root = Tag('svg', attributes)
    @innerHTML = root
    @async(@drawVisualization2, 1)

  drawVisualization2: ->
    oldConfig = window.oldBurnChartConfig
    burnChartSVG = document.getElementById('burn-chart-svg')
    dimensions =
      x: burnChartSVG.x.baseVal.value
      y: burnChartSVG.y.baseVal.value
      width: burnChartSVG.width.baseVal.value
      height: burnChartSVG.height.baseVal.value
    if dimensions.width is 0 or dimensions.height is 0
      @async(@drawVisualization2, 1)
    else
      Line.setDefaultAttributes({'stroke-width': 4})

      leftMargin = 10
      rightMargin = 5
      topMargin = 5
      bottomMargin = 10
      spaceBetween = 0
      topChartHeight = 35
      bottomChartHeight = 50

      chartLeft = leftMargin
      chartRight = 100 - rightMargin
      chartWidth = chartRight - chartLeft

      topChartTop = topMargin
      topChartBottom = topChartTop + topChartHeight
      bottomChartTop = topChartBottom + spaceBetween
      bottomChartBottom = bottomChartTop + bottomChartHeight

      attributes = rootAttributes  # !TODO: Need to copy this
      root = Tag('svg', attributes)
      lowerChart = Tag('g', {id: 'lower-chart'}, root)
      Line.setDefaultAttributes({stroke: 'black','stroke-dasharray': "1,0"})
      bottomChartXAxis = Line(chartLeft, bottomChartBottom, chartRight, bottomChartBottom, null, lowerChart)
      bottomChartYAxis = Line(chartLeft, bottomChartBottom, chartLeft, bottomChartTop, null, lowerChart)

      periodWidth = chartWidth / @config.periods
      x0 = chartLeft
      y0 = bottomChartBottom
#      scale = 1
#      yOffset = 0
      Line.setDefaultAttributes({stroke: 'red'})
      LineSeries(x0, y0, periodWidth, @config.burnSeries, null, lowerChart)
      Line.setDefaultAttributes({stroke: 'green'})
      LineSeries(x0, y0, periodWidth, @config.scopeSeries, null, lowerChart)
      Line.setDefaultAttributes({'stroke-dasharray': "5,7"})
      LineSeries(x0, y0, periodWidth, @config.scopeProjection, null, lowerChart)
      Line.setDefaultAttributes({stroke: 'blue'})
      LineSeries(x0, y0, periodWidth, @config.linearProjection, null, lowerChart)
      Line.setDefaultAttributes({stroke: 'orange'})

      if @config.forecastProjections?
        for series in @config.forecastProjections
          LineSeries(x0, y0, periodWidth, series, null, lowerChart)

        upperChart = Tag('g', {id: 'upper-chart'}, root)

      if @config.histogram
        x0 = chartLeft
        y0 = topChartBottom
        priorX = null
        for point, index in @config.histogram
          x = periodWidth * index + x0
          if priorX?
            if index % 2 is 0
              attributes = {fill: 'blue'}
            else
              attributes = (fill: 'lightblue')
            if point?
              Rect(priorX, y0 - point, periodWidth, point, attributes, upperChart)
          priorX = x





      @innerHTML = root
)