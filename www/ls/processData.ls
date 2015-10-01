names =
  \1   : "Živý plot"
  \2   : "Živý plot s příkopem"
  \3   : "Malý vodní příkop"
  \4   : "Velký Taxisův příkop"
  \5   : "Irská lavice"
  \6   : "Popkovický skok"
  \7   : "Francouzský skok"
  \8   : "Malé zahrádky 1"
  \9   : "Malé zahrádky 2"
  \10  : "Anglický skok"
  \10a : "Prodloužený taxisův příkop"
  \11  : "Živý plot s příkopem"
  \12  : "Živý plot – seskok"
  \13  : "Živý plot"
  \14  : "Poplerův skok"
  \15  : "Drop"
  \16  : "Kamenná zeď"
  \17  : "Hadí příkop"
  \18  : "Velký vodní příkop"
  \19  : "Malý Taxisův příkop"
  \20  : "Velké zahrádky 1"
  \21  : "Velké zahrádky 2"
  \22  : "Suchý příkop"
  \23  : "Proutěná překážka"
  \24  : "Živý plot"
  \25  : "Velký anglický skok"
  \26  : "Suchý příkop"
  \27  : "Havlův skok"
  \28  : "Proutěné překážky 1"
  \29  : "Proutěné překážky 2"
  \30  : "Proutěné překážky 3"

class Skip
  (@number) ->
    @years = [1989 to 2014].map ->
      falls: []
    @yearsGrouped = [1989 to 2014 by 5].map ->
      falls: []
    @fallsSum = 0
    @name = names[@number]

  addFall: (year, data) ->
    @years[year - 1989].falls.push data
    @yearsGrouped[Math.floor (year - 1989) / 5].falls.push data
    @fallsSum++

ig.getData = ->
  skipsAssoc = {}
  skips = for prekazkaCislo in [1 to 30]
    skip = new Skip prekazkaCislo
    skipsAssoc[prekazkaCislo] = skip
    skip
  skips.push = skipsAssoc["10a"] = new Skip "10a"

  d3.tsv.parse ig.data.data, (row) ->
    row.numbers = numbers = if row['překážka']
      row['překážka'].split ", " .map ->
        if it == "10a"
          it
        else
          parseInt it, 10
    else
      []
    row.year = year = parseInt row['rok'], 10
    for number in numbers
      skipsAssoc[number]?addFall year, row
    row

  skips.sort (a, b) -> b.fallsSum - a.fallsSum
  skips
