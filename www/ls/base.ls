{jumps: data, jumpsAssoc} = ig.getData!
container = d3.select ig.containers.base

fullWidth = 630
fullHeight = 440
margin =
  top: 0.5
  bottom: 30
  left: 20
  right: 15

svg = container.append \svg
  ..attr \width fullWidth
  ..attr \height fullHeight

width = fullWidth - margin.left - margin.right
height = fullHeight - margin.top - margin.bottom

drawing = svg.append \g
  ..attr \class \drawing
  ..attr \transform "translate(#{margin.left},#{margin.top})"

yScale = d3.scale.linear!
  ..domain [0 60]
  ..range [height, 0]

xScale = d3.scale.linear!
  ..domain [1971 2014]
  ..range [0 width]

line = d3.svg.line!
  ..x -> Math.round xScale it.year
  ..y -> Math.round yScale it.rate

step = (years) ->
  stepped = [years.0]
  for i in [1 til years.length]
    current = years[i]
    last = years[i - 1]

    diff = current.year - last.year
    steppedYear = last.year + diff * 0.95
    stepped.push {year: steppedYear, falls: last.falls, rate: last.rate}
    stepped.push current
  stepped.push {year: current.year + 1, falls:current.falls, rate: current.rate}
  stepped


lines = drawing.append \g .attr \class \lines
backgroundG = lines.append \g
    ..attr \class \background
    ..selectAll \path .data data.slice 0 5 .enter!append \path
      ..attr \d -> line step it.yearsGrouped
foregroundG = lines.append \g
  ..attr \class \foreground


drawing.append \g .attr \class "axis x"
  ..attr \transform "translate(0, #{height + 5})"
  ..append \line
    ..attr \x2 width
  ..selectAll \g.year .data [1971 to 2014 by 4] .enter!append \g
    ..attr \class \year
    ..attr \transform -> "translate(#{xScale it}, 0)"
    ..append \line
      ..attr \y2 5
    ..append \text
      ..text -> it
      ..attr \text-anchor \middle
      ..attr \y 17

currentDatum = null
move = (dir) ->
  currentIndex = data.indexOf currentDatum
  index = currentIndex + dir
  index %%= data.length
  highlight data[index]

sidebar = new ig.Sidebar container, data
  ..previousRequested = -> move -1
  ..nextRequested = -> move +1
  ..jumpRequested = (jump) ->
    highlight jump

highlight = (datum) ->
  currentDatum := datum
  foregroundG.selectAll \path .data [datum]
    ..enter!append \path
    ..attr \d -> line step it.yearsGrouped
  foregroundG.selectAll \text .data datum.yearsGrouped
    ..enter!append \text
      ..attr \text-anchor \middle
      ..attr \x ->
        if it.year == 2013
          xScale it.year + 0.9
        else
          xScale it.year + 1.9
    ..text ->
      "#{ig.utils.formatNumber it.rate, 2} %"
    ..attr \y -> -5 + yScale it.rate
  sidebar.highlight datum

highlight data.3

