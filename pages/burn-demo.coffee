# !TODO: Either use or remove iron-pages and page.js dependencies

pickOne = (choices) ->
  return choices[Math.floor(Math.random() * choices.length)]

randomProjection = (startIndex, startY, target, slopes) ->
  series = []
  i = 0
  while i < startIndex
    i++
    series.push(null)
  y = startY
  while y < target
    series.push(y)
    y += pickOne(slopes)
    i++
  series.push(y)
  return {series, index: i}


Polymer
  is: "burn-demo"

  ready: ->
    @gestureActive = true
    @step = 0
    lastStep = 20  # !TODO: Need to get the steps in scope and use their length here.
    @steps = Array(lastStep + 1)

  properties:
    step:
      type: Number
      observer: 'stepChanged'
    chartConfig: Object
    dialog: String
    steps: Array

  stepChanged: (step, oldStep = 0) ->
    config = {}
    slopes = startIndex = startY = target = null
    nl = null
    steps = [
      {
        dialog: "This is what your burn-up chart looks like on day 1."
        f: () -> config = {periods: 20}
      }
      {
        dialog: "5 time periods laters, we'll have some data. The slope (rise) of the segment indicates the velocity or throughput for that time period."
        f: () -> config.burnSeries =       [0 , 1 , 8 , 11, 19, 21]
      }
      {
        dialog: "Scope data added. It's pretty much leveled off."
        f: () -> config.scopeSeries =      [37, 42, 44, 44, 47, 48]
      }
      {
        dialog: "So, it's reasonable to assume that it will not grow the rest of the project."
        f: () -> config.scopeProjection =  [nl, nl, nl, nl, nl, 48, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, 48]
      }
      {
        dialog: "Traditional linear forecast identifies one date, but that's only one possible outcome."
        f: () -> config.linearProjection = [0 , nl, nl, nl, nl, 21, nl, nl, nl, nl, nl, nl, 48]
      }
      {
        dialog: "Pretend we have a 5-sided dice, where 1=1st slope (velocity/throughput), 2=2nd slope, etc. We get unlucky and roll a 5 corresponding the shallow slope (low throughput/velocity) of the last time period."
        f: () ->
          config.forecastProjections = [
            [nl, nl, nl, nl, nl, 21, 22.9]
          ]
      }
      {
        dialog: "Unlucky again!"
        f: () ->
          config.forecastProjections = [
            [nl, nl, nl, nl, nl, 21, 22.9, 24.8]
          ]
      }
      {
        dialog: "Unlucky 14 times in a row!!! Notice, the first blue tick mark where it hits the scope line."
        f: () ->
          config.forecastProjections = [
            [nl, nl, nl, nl, nl, 21, 22.9, 24.8, 26.7, 28.6, 30.5, 32.4, 34.3, 36.2, 38.1, 40, 41.9, 43.9, 45.9, 48, nl]
          ]
          config.histogram = []
          for i in [0..config.periods]
            config.histogram.push(0)
          config.histogram[20] = 1
      }
      {
        dialog: "Now we roll a 4 corresponding the highest slope/velocity/throughput."
        f: () ->
          config.forecastProjections = [
            [nl, nl, nl, nl, nl, 21, 22.9, 24.8, 26.7, 28.6, 30.5, 32.4, 34.3, 36.2, 38.1, 40, 41.9, 43.9, 45.9, 48, nl]
            [nl, nl, nl, nl, nl, 21, 30]
          ]
      }
      {
        dialog: "Yippie! Rolled another 4!"
        f: () ->
          config.forecastProjections = [
            [nl, nl, nl, nl, nl, 21, 22.9, 24.8, 26.7, 28.6, 30.5, 32.4, 34.3, 36.2, 38.1, 40, 41.9, 43.9, 45.9, 48, nl]
            [nl, nl, nl, nl, nl, 21, 30, 39]
          ]
        }
      {
        dialog: "Another 4?!?! We're going to Vegas!!!"
        f: () ->
          config.forecastProjections = [
            [nl, nl, nl, nl, nl, 21, 22.9, 24.8, 26.7, 28.6, 30.5, 32.4, 34.3, 36.2, 38.1, 40, 41.9, 43.9, 45.9, 48, nl]
            [nl, nl, nl, nl, nl, 21, 30, 39, 48]
          ]
          config.histogram[8] = 1
        }
      {
        dialog: "But we're not always going to be either lucky or unlucky. We're just as likely to roll a 1, 2, or 3 as we are a 5 or 4. Each set of rolls is another possible forecast. Here's one."
        f: () ->
          # set slopes
          slopes = []
          priorPoint = null
          for point in config.burnSeries
            if priorPoint?
              slopes.push(point - priorPoint)
            priorPoint = point

          # set starting values
          startIndex = config.burnSeries.length - 1
          startY = config.burnSeries[startIndex]
          target = config.scopeSeries[startIndex]

          # generate one projection
          projection = randomProjection(startIndex, startY, target, slopes)
          config.forecastProjections.push(projection.series)
          config.histogram[projection.index]++
        }
      {
        dialog: "Here's five more sets of dice rolls, each representing another possible outcome. Notice the histogram growing up top."
        f: () ->
          # generate 5 more projections
          for i in [1..5]
            projection = randomProjection(startIndex, startY, target, slopes)
            config.forecastProjections.push(projection.series)
            config.histogram[projection.index]++
      }
      {
        dialog: 'What if we roll a few dozen forecasts? Not a smooth curve, but informative.'
        f: () ->
          max = 0
          multiplier = .5
          while max < 35 * multiplier
            projection = randomProjection(startIndex, startY, target, slopes)
            config.forecastProjections.push(projection.series)
            config.histogram[projection.index]++
            max = Math.max(config.histogram[projection.index], max)
          for h, i in config.histogram
            config.histogram[i] = h / multiplier
      }
      {
        dialog: "What if we roll hundreds of forecasts? It's starting to smooth out. It would be very smooth at thousands."
        f: () ->
          max = 0
          multiplier = 5
          while max < 35 * multiplier
            projection = randomProjection(startIndex, startY, target, slopes)
            config.forecastProjections.push(projection.series)
            config.histogram[projection.index]++
            max = Math.max(config.histogram[projection.index], max)
          for h, i in config.histogram
            config.histogram[i] = h / multiplier
      }
      {
        prerequisites: [0, 1, 2]
        dialog: "Let's start over, except this time, let's assume there is a 50% likely risk that will delay the project between 5 and 7 time periods."
        f: () ->
          config.periods = 28

          # initialize scope projection
          config.scopeProjection = []
          startIndex = config.burnSeries.length - 1
          target = config.scopeSeries[startIndex]
          for i in [0..config.scopeSeries.length - 2]
            config.scopeProjection.push(null)
          config.scopeProjection.push(target)
          for i in [config.scopeProjection.length + 1..config.periods]
            config.scopeProjection.push(null)
          config.scopeProjection.push(target)
      }
      {
        dialog: "Notice how the distribution is bimodal and the peaks are 6 time periods (average of 5, 6, and 7) apart."
        f: () ->
          max = 0
          multiplier = 5
          config.forecastProjections = []

          # initialize histogram
          config.histogram = []
          for i in [0..config.periods]
            config.histogram.push(0)

          # set starting values
          startIndex = config.burnSeries.length - 1
          startY = config.burnSeries[startIndex]
          target = config.scopeSeries[startIndex]

          # set slopes
          slopes = []
          priorPoint = null
          for point in config.burnSeries
            if priorPoint?
              slopes.push(point - priorPoint)
            priorPoint = point

          while max < 35 * multiplier
            if Math.random() < 0.5
              delay = 5 + Math.floor(Math.random() * 3)
              adjustedStartIndex = startIndex + delay
            else
              adjustedStartIndex = startIndex
            projection = randomProjection(adjustedStartIndex, startY, target, slopes)
            config.forecastProjections.push(projection.series)
            config.histogram[projection.index]++
            max = Math.max(config.histogram[projection.index], max)
          for h, i in config.histogram
            config.histogram[i] = h / multiplier
      }
      {
        prerequisites: [0, 1, 2]
        dialog: "A 50% risk is not very realistic. Let's see how it would look with a 20% risk and a 10% risk but with larger potential delay."
        f: () ->
          config.periods = 33

          # initialize scope projection
          config.scopeProjection = []
          startIndex = config.burnSeries.length - 1
          target = config.scopeSeries[startIndex]
          for i in [0..config.scopeSeries.length - 2]
            config.scopeProjection.push(null)
          config.scopeProjection.push(target)
          for i in [config.scopeProjection.length + 1..config.periods]
            config.scopeProjection.push(null)
          config.scopeProjection.push(target)
      }
      {
        dialog: "Things get pretty messy and spread out."
        f: () ->
          max = 0
          multiplier = 5
          config.forecastProjections = []

          # initialize histogram
          config.histogram = []
          for i in [0..config.periods]
            config.histogram.push(0)

          # set starting values
          startIndex = config.burnSeries.length - 1
          startY = config.burnSeries[startIndex]
          target = config.scopeSeries[startIndex]

          # set slopes
          slopes = []
          priorPoint = null
          for point in config.burnSeries
            if priorPoint?
              slopes.push(point - priorPoint)
            priorPoint = point

          while max < 35 * multiplier
            adjustedStartIndex = startIndex
            if Math.random() < 0.2
              adjustedStartIndex += 5 + Math.floor(Math.random() * 3)
            if Math.random() < 0.1
              adjustedStartIndex += 10 + Math.floor(Math.random() * 3)

            projection = randomProjection(adjustedStartIndex, startY, target, slopes)
            config.forecastProjections.push(projection.series)
            config.histogram[projection.index]++
            max = Math.max(config.histogram[projection.index], max)
          for h, i in config.histogram
            config.histogram[i] = h / multiplier
      }

    ]
    @steps = steps

    extractPrerequisites = (steps, stepNumber, currentList = []) ->
      currentStep = steps[stepNumber]
      currentList.unshift(stepNumber)
      if currentStep.prerequisites?
        currentList = currentStep.prerequisites.concat(currentList)
        return currentList
      else if stepNumber is 0
        return currentList
      else
        return extractPrerequisites(steps, stepNumber - 1, currentList)

    currentPrerequisites = extractPrerequisites(steps, step)
    for i in currentPrerequisites
      steps[i].f()

    @chartConfig = config

    dialog = steps[step].dialog
    if dialog?
      @dialog = dialog
      @$.intro.open()
    else
      @$.intro.close()

  _listTap: ->
    @$.drawerPanel.closeDrawer()

  forward: ->
    if @step < @steps.length - 1 and @gestureActive
      @gestureActive = false
      @step++
      setTimeout(@enableGesture, 100)

  back: ->
    if @step > 0 and @gestureActive
      @gestureActive = false
      @step--
      setTimeout(@enableGesture, 100)

  enableGesture: ->
    document.querySelector('burn-demo').gestureActive = true
