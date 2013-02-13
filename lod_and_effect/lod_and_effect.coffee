# function that does all of the work
draw = (data) ->

  # take log of phenotype
  log = (x) -> Math.log(x)/Math.LN10
  for i of data.phevals
    data.phevals[i] = log data.phevals[i]
  data.phenotype = "log10 #{data.phenotype}"

  # dimensions of SVG
  w = 1350
  h = 450
  botLw = 650
  pad = {left:60, top:40, right:40, bottom: 40}
  innerPad = 4
  wInner = []
  wInner[0] = w - pad.left - pad.right
  hInner = []
  for i in [0..3]
    hInner[i] = h - pad.top - pad.bottom
  chrGap = 8

  wInner[1] = botLw - pad.left - pad.right
  botRw = (w - botLw)/2
  wInner[2] = botRw - pad.left - pad.right
  wInner[3] = wInner[2]

  # left, right, top, bottom positions for each
  # of the four panels
  left = [pad.left, pad.left, botLw + pad.left, botLw + botRw + pad.left]
  right = []
  for i in [0..3]
    right[i] = left[i] + wInner[i]
  top = []
  bottom = []
  for i in [0..3]
    top[i] = pad.top
    bottom[i] = pad.top + hInner[i]

  # jitter amounts for PXG plot
  jitterAmount = (right[3] - left[3])/50
  jitter = []
  for i of data.phevals
    jitter[i] = (2.0*Math.random()-1.0) * jitterAmount

  # colors definitions
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "#E9CFEC"
  purple = "#8C4374"

  # create SVGs
  topsvg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)
  botsvg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)
  svgs = [topsvg, botsvg, botsvg, botsvg]

  # gray backgrounds
  for j in [0..3]
    svgs[j].append("rect")
           .attr("x", left[j])
           .attr("y", top[j])
           .attr("height", hInner[j])
           .attr("width", wInner[j])
           .attr("class", "innerBox")

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
          up = me + se
          lo = me - se
          effMax = up if effMax is null or effMax < up
          effMin = lo if effMin is null or effMin > lo

  # phenotype max and min
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
    chrPixelEnd[i] = cur + Math.round((wInner[0]-chrGap*(data.chr.length))/totalChrLength*chrLength[i])
    cur = chrPixelEnd[i] + chrGap

  # vertical scales
  xScale = []
  yScale = []
  yScale[0] = d3.scale.linear()
                .domain([0, maxLod*1.02])
                .range([bottom[0], top[0]])
  yScale[1] = yScale[0]

  # chromosome-specific horizontal scales
  xScale[0] = {}
  xScale[1] = {}
  chrColor = {}
  for i in data.chr
    xScale[0][i] = d3.scale.linear()
                     .domain([chrStart[i], chrEnd[i]])
                     .range([chrPixelStart[i], chrPixelEnd[i]])
    xScale[1][i] = d3.scale.linear()
                     .domain([0, chrEnd[i]])
                     .range([left[1]+innerPad, right[1]-innerPad])
    if i % 2
      chrColor[i] = lightGray
    else
      chrColor[i] = darkGray

  yScale[2] = d3.scale.linear()
                .domain([effMin, effMax])
                .range([bottom[2]-innerPad, top[2]+innerPad])
  yScale[3] = d3.scale.linear()
                .domain([pheMin, pheMax])
                .range([bottom[3]-innerPad, top[3]+innerPad])

  average = (x) ->
    sum = 0
    for xv in x
      sum += xv
    sum / x.length

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

     xScale[2] = d3.scale.ordinal()
                   .domain(d3.range(mean.length))
                   .rangePoints([left[2], right[2]], 1)
     xScale[3] = d3.scale.ordinal()
                   .domain(d3.range(mean.length))
                   .rangePoints([left[3], right[3]], 1)

     femaleloc2 = []
     femaleloc3 = []
     maleloc2 = []
     maleloc3 = []
     for i of mean
       if male[i]
         maleloc2.push(xScale[2](i))
         maleloc3.push(xScale[3](i))
       else
         femaleloc2.push(xScale[2](i))
         femaleloc3.push(xScale[3](i))
     aves = [[average(femaleloc2), average(maleloc2)], [average(femaleloc3), average(maleloc3)]]
     
     # lower middle and lower right X axes
     for j in [2..3]
       XaxisGrp[j].selectAll("line").remove()
       XaxisGrp[j].selectAll("text").remove()
       XaxisGrp[j].selectAll("empty")
                  .data(d3.range(mean.length))
                  .enter()
                  .append("line")
                  .attr("y1", top[j])
                  .attr("y2", bottom[j])
                  .attr("x1", (td) -> xScale[j](td))
                  .attr("x2", (td) -> xScale[j](td))
                  .attr("stroke", darkGray)
                  .attr("fill", "none")
                  .attr("stroke-width", "1")
       XaxisGrp[j].selectAll("empty")
                  .data(d3.range(mean.length))
                  .enter()
                  .append("text")
                  .text((td) -> genotypes[td])
                  .attr("y", bottom[j] + pad.bottom*0.25)
                  .attr("x", (td) -> xScale[j](td))
       XaxisGrp[j].selectAll("empty")
                  .data(aves[j-2])
                  .enter()
                  .append("text")
                  .text((td,i) -> ["Female", "Male"][i])
                  .attr("y", bottom[j] + pad.bottom*0.75)
                  .attr("x", (td) -> td)

     effplot = botsvg.append("g")

     effplot.selectAll("empty")
         .data(mean)
         .enter()
         .append("line")
         .attr("class", "effectplot")
         .attr("x1", (d,i) -> xScale[2](i))
         .attr("x2", (d,i) -> xScale[2](i))
         .attr("y1", (d,i) -> yScale[2](lo[i]))
         .attr("y2", (d,i) -> yScale[2](hi[i]))
         .attr("fill", "none")
         .attr("stroke", "black")
         .attr("stroke-width", "2")

     effplot.selectAll("empty")
         .data(mean)
         .enter()
         .append("circle")
         .attr("class", "effectplot")
         .attr("cx", (d,i) -> xScale[2](i))
         .attr("cy", (d) -> yScale[2](d))
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
     .attr("height", (d) -> hInner[0])
     .attr("fill", (d) -> chrColor[d])
     .attr("stroke", "none")

  # groups to hold all of the xAxis elements
  XaxisGrp = []
  YaxisGrp = []
  for j in [0..3]
    XaxisGrp[j] = svgs[j].append("g").attr("id", "Xaxis#{j}").attr("class", "axis")
    YaxisGrp[j] = svgs[j].append("g").attr("id", "Yaxis#{j}").attr("class", "axis")

  nTicks = [10, 10, 6, 6]
  nLabels = [6, 6, 6, 6]
  for j in [0..3]
    YaxisGrp[j].selectAll("empty")
               .data(yScale[j].ticks(nTicks[j]))
               .enter()
               .append("line")
               .attr("y1", (d) -> yScale[j](d))
               .attr("y2", (d) -> yScale[j](d))
               .attr("x1", left[j])
               .attr("x2", right[j])
               .attr("stroke", "white")
               .attr("fill", "none")
               .attr("stroke-width", "1")
    YaxisGrp[j].selectAll("empty")
               .data(yScale[j].ticks(nLabels[j]))
               .enter()
               .append("text")
               .text((d) -> d)
               .attr("x", left[j] - pad.left*0.05)
               .attr("y", (d) -> yScale[j](d))
               .attr("class", "alignright")

  # y-axis titles
  ylab = ["LOD score", "LOD score", data.phenotype, data.phenotype]
  xpos = [pad.left/2, pad.left/2, left[2]-pad.left*0.6, left[3]-pad.left*0.7]
  for j in [0..3]
    YaxisGrp[j].append("text")
               .text(ylab[j])
               .attr("x", xpos[j])
               .attr("y", (top[j]+bottom[j])/2)
               .attr("transform", "rotate(270,#{xpos[j]},#{(top[j]+bottom[j])/2})")
               .attr("fill", "blue")

  # title on top panel
  topsvg.append("text")
     .text(data.phenotype)
     .attr("x", (left[0] + right[0])/2)
     .attr("y", pad.top/2)
     .attr("fill", "blue")

  # x-axis labels
  xlab = ["Chromosome", "Position (cM)"]
  for j in [0..1]
    XaxisGrp[j].append("text")
               .text(xlab[j])
               .attr("x", (left[j] + right[j])/2)
               .attr("y", bottom[j] + pad.bottom*0.65)
               .attr("fill", "blue")

  # lod curves by chr
  lodcurve = (j) ->
      d3.svg.line()
        .x((d) -> xScale[0][j](d))
        .y((d,i) -> yScale[0](data.lod[j].lod[i]))

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
          .x((d) -> xScale[1][j](d))
          .y((d,i) -> yScale[1](data.lod[j].lod[i]))

  randomDraw = (x) -> x[Math.floor(Math.random()*x.length)]

  randomChr = randomDraw(data.chr)
  randomMarker = randomDraw(data.markers[randomChr])

  # initial phenotype vs genotype plot
  initialPXG = (chr, marker) ->
    botsvg.selectAll("empty")
          .data(data.phevals)
          .enter()
          .append("circle")
          .attr("class", "plotPXG")
          .attr("cx", (d,i) ->
              g = Math.abs(data.geno[marker][i])
              sx = data.sex[i]
              if(chr=="X")
                return xScale[3](sx*2+g-1)+jitter[i]
              xScale[3](sx*3+g-1)+jitter[i])
          .attr("cy", (d) -> yScale[3](d))
          .attr("r", "3")
          .attr("fill", (d,i) ->
              g = data.geno[marker][i]
              return pink if g < 0
              darkGray)
           .attr("stroke", (d,i) ->
               g = data.geno[marker][i]
               return purple if g < 0
               "black")
          .attr("stroke-width", (d,i) ->
               g = data.geno[marker][i]
               return "2" if g < 0
               "1")

  # function to revise phenotype vs genotype plot
  revPXG = (chr, marker) ->
    botsvg.selectAll(".plotPXG")
           .transition().duration(1000)
           .attr("cx", (d,i) ->
               g = Math.abs(data.geno[marker][i])
               sx = data.sex[i]
               if(chr=="X")
                 return xScale[3](sx*2+g-1)+jitter[i]
               xScale[3](sx*3+g-1)+jitter[i])
           .attr("fill", (d,i) ->
               g = data.geno[marker][i]
               return pink if g < 0
               darkGray)
           .attr("stroke", (d,i) ->
               g = data.geno[marker][i]
               return purple if g < 0
               "black")
           .attr("stroke-width", (d,i) ->
               g = data.geno[marker][i]
               return "2" if g < 0
               "1")

  botsvg.append("g").append("path")
       .attr("d", botlodcurve(randomChr)(data.lod[randomChr].pos))
       .attr("class", "thickline")
       .attr("id", "detailedLod")
       .attr("stroke", "blue")
       .style("pointer-events", "none")
  botsvg.append("text")
        .attr("x", (left[1] + right[1])/2)
        .attr("y", pad.top/2)
        .text("Chromosome #{randomChr}")
        .attr("id", "botLtitle")
        .attr("fill", "blue")
  botsvg.append("text")
        .attr("x", (left[2]+right[3])/2)
        .attr("y", pad.top/2)
        .text("")
        .attr("id", "botRtitle")
        .attr("fill", "blue")

  XaxisGrp[1].selectAll("empty")
              .data(xScale[1][randomChr].ticks(10))
              .enter()
              .append("line")
              .attr("class", "axis")
              .attr("y1", top[1])
              .attr("y2", bottom[1])
              .attr("x1", (td) -> xScale[1][randomChr](td))
              .attr("x2", (td) -> xScale[1][randomChr](td))
              .attr("stroke", darkGray)
              .attr("fill", "none")
              .attr("stroke-width", "1")
  XaxisGrp[1].selectAll("empty")
              .data(xScale[1][randomChr].ticks(10))
              .enter()
              .append("text")
              .attr("class", "axis")
              .text((td) -> td)
              .attr("y", bottom[1] + pad.bottom*0.25)
              .attr("x", (td) -> xScale[1][randomChr](td))

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
          .attr("cx", (td) -> xScale[1][chr](data.lod[chr].pos[data.markerindex[chr][td]]))
          .attr("cy", (td) -> yScale[1](data.lod[chr].lod[data.markerindex[chr][td]]))
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
                 revPXG chr, td
                 unless randomMarker is ""
                   d3.select("#circle#{randomMarker}")
                     .attr("opacity", 0)
                     .attr("fill",purple)
                     .attr("stroke","none")
                   randomMarker = ""

  dotsAtMarkers(randomChr)

  # Initial "click" of the random marker
  pos = data.lod[randomChr].pos[data.markerindex[randomChr][randomMarker]]
  title = "#{randomMarker} (chr #{randomChr}, #{onedig(pos)} cM)"
  d3.select("text#botRtitle").text(title)
  d3.select("#circle#{randomMarker}").attr("opacity", 1).attr("fill",pink).attr("stroke",purple)
  effectPlot randomChr, randomMarker
  initialPXG randomChr, randomMarker

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

               XaxisGrp[1].selectAll("line.axis").remove()
               XaxisGrp[1].selectAll("text.axis").remove()

               XaxisGrp[1].selectAll("empty")
                           .data(xScale[1][d].ticks(10))
                           .enter()
                           .append("line")
                           .attr("class", "axis")
                           .attr("y1", top[1])
                           .attr("y2", bottom[1])
                           .attr("x1", (td) -> xScale[1][d](td))
                           .attr("x2", (td) -> xScale[1][d](td))
                           .attr("stroke", darkGray)
                           .attr("fill", "none")
                           .attr("stroke-width", "1")
               XaxisGrp[1].selectAll("empty")
                           .data(xScale[1][d].ticks(10))
                           .enter()
                           .append("text")
                           .attr("class", "axis")
                           .text((td) -> td)
                           .attr("y", bottom[1] + pad.bottom*0.25)
                           .attr("x", (td) -> xScale[1][d](td))

  # chr labels
  topsvg.append("g").selectAll("empty")
    .data(data.chr)
    .enter()
    .append("text")
    .text((d) -> d)
    .attr("x", (d) -> Math.floor((chrPixelStart[d] + chrPixelEnd[d])/2))
    .attr("y", bottom[0] + pad.bottom*0.3)

  # black borders
  for j in [0..3]
    svgs[j].append("rect")
           .attr("x", left[j])
           .attr("y", top[j])
           .attr("height", hInner[j])
           .attr("width", wInner[j])
           .attr("class", "outerBox")

# load json file and call draw function
d3.json("insulinlod.json", draw)
