class ig.Sidebar
  (@parentElement) ->
    @element = @parentElement.append \div
      ..attr \class \sidebar
    @drawTexts!
    @drawMap!

  highlight: (datum) ->
    jump = @jumpsAssoc[datum.number]
    @heading.html "#{jump.number}. #{jump.name}"
    @content.html jump.comment


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

    jumps = d3.csv.parse ig.data.jumps, (row) ~>
      row.lat = parseFloat row.Y
      row.lon = parseFloat row.X
      row.coords = projection [row.lon, row.lat]
      @jumpsAssoc[row.number] = row
      row

    @jumps = @map.selectAll \circle .data jumps .enter!append \circle
      ..attr \cx (.coords.0)
      ..attr \cy (.coords.1)
      ..attr \r 5
    voronoi = d3.geom.voronoi!
      ..x ~> it.coords.0
      ..y ~> it.coords.1
      ..clipExtent [[0, 0], [width, height]]
    voronoiPolygons = voronoi jumps
      .filter -> it && it.length

    @vororoi = @map.append \g .attr \class \voronoi
      .selectAll \path .data voronoiPolygons .enter!append \path
        ..attr \d polygon

polygon = ->
  "M#{it.join "L"}Z"
