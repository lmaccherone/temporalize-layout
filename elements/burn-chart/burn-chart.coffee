Polymer(
  is: "burn-chart"
  created: ->
    svg = window.yako.svg
    root = svg.create('svg').attr({
      id: 'burn-chart'
      xmlns: "http://www.w3.org/2000/svg"
      width: '100%'
      height: '100%'
      'xmlns:xlink': "http://www.w3.org/1999/xlink"
    })
    rect = '<rect id="SvgjsRect1006" width="100%" height="300" x="0" y="0" fill="none" stroke="#000000" stroke-width="1"></rect>'
    root.append(rect)
    @innerHTML = root.stringify()
)