
yearStart = 1971
yearEnd = 2014
yearGroupping = 4
class Jump
  (data) ->
    @number = data.number
    @comment = data.comment
    @years = [yearStart to yearEnd].map (year) ->
      year: year
      rate: parseFloat data[year]
    @yearsGrouped = [0 til @years.length by yearGroupping].map (yearIndex) ~>
      year = @years[yearIndex].year
      rate = 0
      averagedFrom = for next in [0 til yearGroupping]
        rate += @years[yearIndex + next].rate / yearGroupping
        @years[yearIndex + next]
      {year, rate, averagedFrom}

    @name = data.name
    @coords = []
    @addCooords data

  addCooords: ({lon, lat}) ->
    @coords.push do
      [lon, lat].map parseFloat


ig.getData = ->
  jumpsAssoc = {}
  jumps = []
  for row in d3.csv.parse ig.data.jumps
    if row.comment
      jump = new Jump row
      jumps.push jump
      jumpsAssoc[jump.number] = jump
    else
      jumps[*-1].addCooords row

  {jumps, jumpsAssoc}
