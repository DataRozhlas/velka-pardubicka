class ig.Sidebar
  (@parentElement, @data) ->
    @element = @parentElement.append \div
      ..attr \class \sidebar
    @drawTexts!
    @drawMap!

  highlight: (jump) ->
    @heading.html "#{jump.number}. #{jump.name}"
    @content.html jump.comment
    @jumps.classed \active -> it is jump

  drawTexts: ->
    @heading = @element.append \h2
    @arrows = @element.append \div
      ..attr \class \arrow
      ..append \a
        ..html "« předchozí"
        ..attr \href \#
        ..on \click ~>
          d3.event.preventDefault!
          @previousRequested!
      ..append \a
        ..html "následující »"
        ..attr \href \#
        ..on \click ~>
          d3.event.preventDefault!
          @nextRequested!
    @content = @element.append \p

  drawMap: ->
    geojson = ig.data.map
    {width, height, projection} = ig.utils.geo.getFittingProjection do
      geojson.features
      190
    path = d3.geo.path!
      ..projection projection

    @map = @element.append \svg
      ..attr \width width
      ..attr \height height + 2
      ..append \path
        ..attr \d path geojson.features.0.geometry

    @jumpsAssoc = {}

    individualJumps = []
    for jump in @data
      for coord in jump.coords
        coord.projected = projection coord
        individualJumps.push {coord, jump}

    @jumps = @map.selectAll \g.jump .data @data .enter!append \g
      ..attr \class \jump
      ..selectAll \circle .data (.coords) .enter!append \circle
        ..attr \cx -> it.projected.0
        ..attr \cy -> it.projected.1
        ..attr \r 5
    voronoi = d3.geom.voronoi!
      ..x ~> it.coord.projected.0
      ..y ~> it.coord.projected.1
      ..clipExtent [[0, 0], [width, height]]

    voronoiPolygons = voronoi individualJumps
      .filter -> it && it.length

    @vororoi = @map.append \g .attr \class \voronoi
      .selectAll \path .data voronoiPolygons .enter!append \path
        ..attr \d polygon
        ..on \click ~> @jumpRequested it.point.jump
        ..on \mouseover ({{jump}:point}) ~>
          @jumps.classed \hover -> it is jump
        ..on \mouseout ({point}) ~> @jumps.classed \hover no

polygon = ->
  "M#{it.join "L"}Z"
