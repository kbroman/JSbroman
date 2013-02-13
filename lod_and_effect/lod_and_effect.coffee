# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 1350
  h = 450
  pad = {left:60, top:20, right:40, bottom: 40}
  wInner = w - pad.left - pad.right
  hInner = h - pad.top - pad.bottom
  chrGap = 8
  botLw = 650
  botLwInner = botLw - pad.left - pad.right
  botRw = (w - botLw)/2
  botRwInner = botRw - pad.left - pad.right

  topLeft = pad.left
  topRight = pad.left + wInner
  botLeft =  [pad.left, botLw + pad.left, botLw + botRw + pad.left]
  botRight = [pad.left+botLwInner, botLw + pad.left+botRwInner, botLw + botRw + pad.left + botRwInner]

  topsvg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  botsvg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "#E9CFEC"
  purple = "#8C4374"

  # gray backgrounds
  topsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wInner)
     .attr("class", "innerBox")
     .style("pointer-events", "none")
  botsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botLwInner)
     .attr("class", "innerBox")
     .style("pointer-events", "none")
  botsvg.append("rect")
     .attr("x", botLeft[1])
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botRwInner)
     .attr("class", "innerBox")
     .style("pointer-events", "none")
  botsvg.append("rect")
     .attr("x", botLeft[2])
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botRwInner)
     .attr("class", "innerBox")
     .style("pointer-events", "none")

  # maximum LOD score
  maxLod = 0
  for i in data.chr
    currentMax = d3.max(data.lod[i].lod)
    maxLod = currentMax if maxLod < currentMax

  # maximum effect + SE and minimum effect - SE
  effMax = null
  effMin = null
  for mar of data.effects
    for g of data.effects[mar].Means
      for sex of data.effects[mar].Means[g]
        me = data.effects[mar].Means[g][sex]
        se = data.effects[mar].SEs[g][sex]
        if me isnt null
          top = me + se
          bot = me - se
          effMax = top if effMax is null or effMax < top
          effMin = bot if effMin is null or effMin > bot

  pheMax = d3.max(data.phevals)
  pheMin = d3.min(data.phevals)

  # start and end of each chromosome
  chrStart = {}
  chrEnd = {}
  chrLength = {}
  totalChrLength = 0
  for i in data.chr
    chrStart[i] = d3.min(data.lod[i].pos)
    chrEnd[i] = d3.max(data.lod[i].pos)
    chrLength[i] = chrEnd[i] - chrStart[i]
    totalChrLength += chrLength[i]

  chrPixelStart = {}
  chrPixelEnd = {}
  cur = Math.round(pad.left + chrGap/2)
  for i in data.chr
    chrPixelStart[i] = cur
    chrPixelEnd[i] = cur + Math.round((wInner-chrGap*(data.chr.length))/totalChrLength*chrLength[i])
    cur = chrPixelEnd[i] + chrGap

  # vertical scales
  yScale = d3.scale.linear()
             .domain([0, maxLod*1.02])
             .range([hInner+pad.top, pad.top])

  # chromosome-specific horizontal scales
  xScale = {}
  botLxScale = {}
  chrColor = {}
  for i in data.chr
    xScale[i] = d3.scale.linear()
                  .domain([chrStart[i], chrEnd[i]])
                  .range([chrPixelStart[i], chrPixelEnd[i]])
    botLxScale[i] = d3.scale.linear()
                  .domain([0, chrEnd[i]])
                  .range([pad.left, pad.left + botLwInner - chrGap/2])
    if i % 2
      chrColor[i] = lightGray
    else
      chrColor[i] = darkGray

  botMyScale = d3.scale.linear()
                 .domain([effMin, effMax])
                 .range([pad.top+hInner-5, pad.top+5])
  botRyScale = d3.scale.linear()
                 .domain([pheMin, pheMax])
                 .range([pad.top+hInner-5, pad.top+5])

  average = (x) ->
    sum = 0
    for xv in x
      sum += xv
    sum / x.length

  botMXaxisGrp = botsvg.append("g")
  botRXaxisGrp = botsvg.append("g")

  effectPlot = (chr, mar) ->
    botsvg.selectAll(".effectplot").remove()
    mean = []
    lo = []
    hi = []
    male = []
    genotypes = []
    for sex in ["Female", "Male"]
      for g of data.effects[mar].Means
        me = data.effects[mar].Means[g][sex]
        se = data.effects[mar].SEs[g][sex]
        if me isnt null
          mean.push(me)
          lo.push(me-se)
          hi.push(me+se)
          male.push(sex is "Male")
          genotypes.push(g)

     botMxScale = d3.scale.ordinal()
         .domain(d3.range(mean.length))
         .rangePoints([botLeft[1], botRight[1]], 1)
     botRxScale = d3.scale.ordinal()
         .domain(d3.range(mean.length))
         .rangePoints([botLeft[2], botRight[2]], 1)

     femaleloc = []
     maleloc = []
     for i of mean
       if male[i]
         maleloc.push(botMxScale(i))
       else
         femaleloc.push(botMxScale(i))
     aves = [average(femaleloc), average(maleloc)]

     botMXaxisGrp.selectAll(".botMXaxis").remove()
     botRXaxisGrp.selectAll(".botRXaxis").remove()

     botMXaxisGrp.selectAll("empty")
                 .data(d3.range(mean.length))
                 .enter()
                 .append("line")
                 .attr("class", "botMXaxis")
                 .attr("y1", pad.top)
                 .attr("y2", pad.top+hInner)
                 .attr("x1", (td) -> botMxScale(td))
                 .attr("x2", (td) -> botMxScale(td))
                 .attr("stroke", darkGray)
                 .attr("fill", "none")
                 .attr("stroke-width", "1")
     botMXaxisGrp.selectAll("empty")
                 .data(d3.range(mean.length))
                 .enter()
                 .append("text")
                 .attr("class", "botMXaxis")
                 .text((td) -> genotypes[td])
                 .attr("y", pad.top + hInner + pad.bottom*0.25)
                 .attr("x", (td) -> botMxScale(td))
     botMXaxisGrp.selectAll("empty")
                 .data(aves)
                 .enter()
                 .append("text")
                 .attr("class", "botMXaxis")
                 .text((td,i) -> ["Female", "Male"][i])
                 .attr("y", pad.top + hInner + pad.bottom*0.75)
                 .attr("x", (td) -> td)

     botRXaxisGrp.selectAll("empty")
                 .data(d3.range(mean.length))
                 .enter()
                 .append("line")
                 .attr("class", "botRXaxis")
                 .attr("y1", pad.top)
                 .attr("y2", pad.top+hInner)
                 .attr("x1", (td) -> botRxScale(td))
                 .attr("x2", (td) -> botRxScale(td))
                 .attr("stroke", darkGray)
                 .attr("fill", "none")
                 .attr("stroke-width", "1")
     botRXaxisGrp.selectAll("empty")
                 .data(d3.range(mean.length))
                 .enter()
                 .append("text")
                 .attr("class", "botRXaxis")
                 .text((td) -> genotypes[td])
                 .attr("y", pad.top + hInner + pad.bottom*0.25)
                 .attr("x", (td) -> botRxScale(td))
     botRXaxisGrp.selectAll("empty")
                 .data(aves)
                 .enter()
                 .append("text")
                 .attr("class", "botRXaxis")
                 .text((td,i) -> ["Female", "Male"][i])
                 .attr("y", pad.top + hInner + pad.bottom*0.75)
                 .attr("x", (td) -> td + botRw)

     effplot = botsvg.append("g")

     effplot.selectAll("empty")
         .data(mean)
         .enter()
         .append("line")
         .attr("class", "effectplot")
         .attr("x1", (d,i) -> botMxScale(i))
         .attr("x2", (d,i) -> botMxScale(i))
         .attr("y1", (d,i) -> botMyScale(lo[i]))
         .attr("y2", (d,i) -> botMyScale(hi[i]))
         .attr("fill", "none")
         .attr("stroke", "black")
         .attr("stroke-width", "2")

     effplot.selectAll("empty")
         .data(mean)
         .enter()
         .append("circle")
         .attr("class", "effectplot")
         .attr("cx", (d,i) -> botMxScale(i))
         .attr("cy", (d) -> botMyScale(d))
         .attr("r", 6)
         .attr("fill", (d,i) ->
            return "blue" if male[i]
            "red")
         .attr("stroke", "black")
         .attr("stroke-width", "2")

  # background rectangles for each chromosome, alternate color
  chrRect = topsvg.append("g").selectAll("empty")
     .data(data.chr)
     .enter()
     .append("rect")
     .attr("id", (d) -> "rect#{d}")
     .attr("x", (d) -> chrPixelStart[d] - chrGap/2)
     .attr("y", pad.top)
     .attr("width", (d) -> chrPixelEnd[d] - chrPixelStart[d]+chrGap)
     .attr("height", (d) -> hInner)
     .attr("fill", (d) -> chrColor[d])
     .attr("stroke", "none")

  # axes
  topXaxisGrp = topsvg.append("g")
  botLXaxisGrp = botsvg.append("g")
  botMXaxisGrp = botsvg.append("g")
  botRXaxisGrp = botsvg.append("g")
  topYaxisGrp = topsvg.append("g")
  botLYaxisGrp = botsvg.append("g")
  botMYaxisGrp = botsvg.append("g")
  botRYaxisGrp = botsvg.append("g")

  topYaxisGrp.selectAll("empty")
    .data(yScale.ticks(10))
    .enter()
    .append("line")
    .attr("y1", (d) -> yScale(d))
    .attr("y2", (d) -> yScale(d))
    .attr("x1", pad.left)
    .attr("x2", pad.left+wInner)
    .attr("stroke", "white")
    .attr("fill", "none")
    .attr("stroke-width", "1")

  topYaxisGrp.selectAll("empty")
    .data(yScale.ticks(6))
    .enter()
    .append("text")
    .text((d) -> d)
    .attr("x", pad.left*0.8)
    .attr("y", (d) -> yScale(d))

  botLYaxisGrp.selectAll("empty")
    .data(yScale.ticks(10))
    .enter()
    .append("line")
    .attr("y1", (d) -> yScale(d))
    .attr("y2", (d) -> yScale(d))
    .attr("x1", pad.left)
    .attr("x2", pad.left+botLwInner)
    .attr("stroke", "white")
    .attr("fill", "none")
    .attr("stroke-width", "1")
  botLYaxisGrp.selectAll("empty")
    .data(yScale.ticks(6))
    .enter()
    .append("text")
    .text((d) -> d)
    .attr("x", pad.left*0.8)
    .attr("y", (d) -> yScale(d))

  botMYaxisGrp.selectAll("empty")
    .data(botMyScale.ticks(6))
    .enter()
    .append("line")
    .attr("y1", (d) -> botMyScale(d))
    .attr("y2", (d) -> botMyScale(d))
    .attr("x1", botLw + pad.left)
    .attr("x2", botLw + pad.left + botRwInner)
    .attr("stroke", "white")
    .attr("fill", "none")
    .attr("stroke-width", "1")
  botMYaxisGrp.selectAll("empty")
    .data(botMyScale.ticks(6))
    .enter()
    .append("text")
    .text((d) -> d)
    .attr("x", botLw + pad.left*0.8)
    .attr("y", (d) -> botMyScale(d))

  botRYaxisGrp.selectAll("empty")
    .data(botRyScale.ticks(6))
    .enter()
    .append("line")
    .attr("y1", (d) -> botRyScale(d))
    .attr("y2", (d) -> botRyScale(d))
    .attr("x1", botLeft[2])
    .attr("x2", botRight[2])
    .attr("stroke", "white")
    .attr("fill", "none")
    .attr("stroke-width", "1")
  botRYaxisGrp.selectAll("empty")
    .data(botRyScale.ticks(6))
    .enter()
    .append("text")
    .attr("class", "alignright")
    .text((d) -> d)
    .attr("x", botLeft[2] - pad.left*0.08)
    .attr("y", (d) -> botRyScale(d))
    .attr("text-anchor", "end")

  # y-axis labels
  topYaxisGrp.append("text")
    .text("LOD score")
    .attr("x", pad.left/2)
    .attr("y", pad.top + hInner/2)
    .attr("transform", "rotate(270,#{pad.left/2},#{pad.top+hInner/2})")
    .attr("fill", "blue")
  botLYaxisGrp.append("text")
    .text("LOD score")
    .attr("x", pad.left/2)
    .attr("y", pad.top + hInner/2)
    .attr("transform", "rotate(270,#{pad.left/2},#{pad.top+hInner/2})")
    .attr("fill", "blue")

  botMYaxisGrp.append("text")
    .text(data.phenotype)
    .attr("x", botLw + pad.left*0.4)
    .attr("y", pad.top + hInner/2)
    .attr("transform", "rotate(270,#{botLw+pad.left*0.4},#{pad.top+hInner/2})")
    .attr("fill", "blue")
  topsvg.append("text")
     .text(data.phenotype)
     .attr("x", pad.left + wInner/2)
     .attr("y", pad.top/2)
     .attr("fill", "blue")
  botRYaxisGrp.append("text")
    .text(data.phenotype)
    .attr("x", botLeft[2] - pad.left*0.7)
    .attr("y", pad.top + hInner/2)
    .attr("transform", "rotate(270,#{botLeft[2]-pad.left*0.7},#{pad.top+hInner/2})")
    .attr("fill", "blue")


  # x-axis labels
  topXaxisGrp.append("text")
    .text("Chromosome")
    .attr("x", pad.left + wInner/2)
    .attr("y", pad.top + hInner + pad.bottom*0.65)
    .attr("fill", "blue")

  topsvg.append("text")
     .text(data.phenotype)
     .attr("x", pad.left + wInner/2)
     .attr("y", pad.top/2)
     .attr("fill", "blue")

  botLXaxisGrp.append("text")
    .text("Position (cM)")
    .attr("x", pad.left + botLwInner/2)
    .attr("y", pad.top + hInner + pad.bottom*0.65)
    .attr("fill", "blue")

  # lod curves by chr
  lodcurve = (j) ->
      d3.svg.line()
        .x((d) -> xScale[j](d))
        .y((d,i) -> yScale(data.lod[j].lod[i]))

  curves = topsvg.append("g")

  for j in data.chr
    curves.append("path")
          .datum(data.lod[j].pos)
          .attr("d", lodcurve(j))
          .attr("class", "thickline")
          .attr("stroke", "blue")
          .style("pointer-events", "none")

  # detailed LOD curves below
  botlodcurve = (j) ->
      d3.svg.line()
          .x((d) -> botLxScale[j](d))
          .y((d,i) -> yScale(data.lod[j].lod[i]))

  randomChr = data.chr[Math.floor(Math.random()*data.chr.length)]

  botsvg.append("g").append("path")
       .attr("d", botlodcurve(randomChr)(data.lod[randomChr].pos))
       .attr("class", "thickline")
       .attr("id", "detailedLod")
       .attr("stroke", "blue")
       .style("pointer-events", "none")

  botsvg.append("text")
        .attr("x", pad.left + botLwInner/2)
        .attr("y", pad.top/2)
        .text("Chromosome #{randomChr}")
        .attr("id", "botLtitle")
        .attr("fill", "blue")

  botsvg.append("text")
        .attr("x", botLw + pad.left + botRwInner/2)
        .attr("y", pad.top/2)
        .text("")
        .attr("id", "botRtitle")
        .attr("fill", "blue")

  botLXaxisGrp.selectAll("empty")
              .data(botLxScale[randomChr].ticks(10))
              .enter()
              .append("line")
              .attr("class", "botLXaxis")
              .attr("y1", pad.top)
              .attr("y2", pad.top+hInner)
              .attr("x1", (td) -> botLxScale[randomChr](td))
              .attr("x2", (td) -> botLxScale[randomChr](td))
              .attr("stroke", darkGray)
              .attr("fill", "none")
              .attr("stroke-width", "1")

  botLXaxisGrp.selectAll("empty")
              .data(botLxScale[randomChr].ticks(10))
              .enter()
              .append("text")
              .attr("class", "botLXaxis")
              .text((td) -> td)
              .attr("y", pad.top + hInner + pad.bottom*0.25)
              .attr("x", (td) -> botLxScale[randomChr](td))


  onedig = d3.format(".1f")

  # dots at markers
  dotsAtMarkers = (chr) ->
    markerClick = {}
    for m in data.markers[chr]
      markerClick[m] = 0
    lastMarker = ""
    markerCircle = botsvg.append("g").selectAll("empty")
          .data(data.markers[chr])
          .enter()
          .append("circle")
          .attr("class", "markercircle")
          .attr("id", (td) -> "circle#{td}")
          .attr("cx", (td) -> botLxScale[chr](data.lod[chr].pos[data.markerindex[chr][td]]))
          .attr("cy", (td) -> yScale(data.lod[chr].lod[data.markerindex[chr][td]]))
          .attr("r", 6)
          .attr("fill", purple)
          .attr("stroke", "none")
          .attr("stroke-width", "2")
          .attr("opacity", 0)
          .on "mouseover", ->
                 d3.select(this).attr("opacity", 1)
          .on "mouseout", (td) ->
                 d3.select(this).attr("opacity", markerClick[td])
          .on "click", (td) ->
                 pos = data.lod[chr].pos[data.markerindex[chr][td]]
                 title = "#{td} (chr #{chr}, #{onedig(pos)} cM)"
                 d3.select("text#botRtitle").text(title)
                 markerClick[lastMarker] = 0
                 d3.select("#circle#{lastMarker}").attr("opacity", 0).attr("fill",purple).attr("stroke","none")
                 lastMarker = td
                 markerClick[td] = 1
                 d3.select(this).attr("opacity", 1).attr("fill",pink).attr("stroke",purple)
                 effectPlot chr, td

  dotsAtMarkers(randomChr)

  # select chromosome for lower LOD detailed curve
  lastChr = randomChr
  topsvg.select("#rect#{randomChr}").attr("fill", pink)
  chrRect.on "click", (d) ->
             d3.select(this).attr("fill", pink)
             if lastChr != d
               topsvg.select("#rect#{lastChr}").attr("fill", chrColor[lastChr]) if lastChr != 0
               lastChr = d
               botsvg.select("path#detailedLod")
                  .attr("d", botlodcurve(d)(data.lod[d].pos))
               botsvg.selectAll("circle.markercircle").remove()
               dotsAtMarkers(d)
               d3.select("text#botLtitle").text("Chromosome #{d}")
               botLXaxisGrp.selectAll(".botLXaxis").remove()
               botLXaxisGrp.selectAll("empty")
                           .data(botLxScale[d].ticks(10))
                           .enter()
                           .append("line")
                           .attr("class", "botLXaxis")
                           .attr("y1", pad.top)
                           .attr("y2", pad.top+hInner)
                           .attr("x1", (td) -> botLxScale[d](td))
                           .attr("x2", (td) -> botLxScale[d](td))
                           .attr("stroke", darkGray)
                           .attr("fill", "none")
                           .attr("stroke-width", "1")
               botLXaxisGrp.selectAll("empty")
                           .data(botLxScale[d].ticks(10))
                           .enter()
                           .append("text")
                           .attr("class", "botLXaxis")
                           .text((td) -> td)
                           .attr("y", pad.top + hInner + pad.bottom*0.25)
                           .attr("x", (td) -> botLxScale[d](td))

  # chr labels
  topsvg.append("g").selectAll("empty")
    .data(data.chr)
    .enter()
    .append("text")
    .text((d) -> d)
    .attr("x", (d) -> Math.floor((chrPixelStart[d] + chrPixelEnd[d])/2))
    .attr("y", pad.top + hInner + pad.bottom*0.3)

  # black borders
  topsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wInner)
     .attr("class", "outerBox")
     .style("pointer-events", "none")
  botsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botLwInner)
     .attr("class", "outerBox")
     .style("pointer-events", "none")
  botsvg.append("rect")
     .attr("x", botLeft[1])
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botRwInner)
     .attr("class", "outerBox")
     .style("pointer-events", "none")
  botsvg.append("rect")
     .attr("x", botLeft[2])
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botRwInner)
     .attr("class", "outerBox")
     .style("pointer-events", "none")


# load json file and call draw function
d3.json("insulinlod.json", draw)
