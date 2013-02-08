# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 1000
  h = 450
  pad = {left:60, top:20, right:40, bottom: 40}
  wInner = w - pad.left - pad.right
  hInner = h - pad.top - pad.bottom
  chrGap = 8
  botLw = 650
  botLwInner = botLw - pad.left - pad.right
  botRw = w - botLw
  botRwInner = botRw - pad.left - pad.right

  topsvg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  botsvg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)

  # gray backgrounds
  topsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wInner)
     .attr("class", "innerBox")

  botsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botLwInner)
     .attr("class", "innerBox")

  botsvg.append("rect")
     .attr("x", botLw+pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botRwInner)
     .attr("class", "innerBox")


  # maximum LOD score
  maxLod = 0
  for i in data.chr
    currentMax = d3.max(data.lod[i].lod)
    maxLod = currentMax if maxLod < currentMax

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
                  .domain([chrStart[i], chrEnd[i]])
                  .range([pad.left + chrGap/2, pad.left + botLwInner - chrGap/2])
    if i % 2
      chrColor[i] = lightGray
    else
      chrColor[i] = darkGray


  # background rectangles for each chromosome, alternate color
  chrRect = topsvg.append("g").selectAll("empty")
     .data(data.chr)
     .enter()
     .append("rect")
     .attr("x", (d) -> chrPixelStart[d] - chrGap/2)
     .attr("y", pad.top)
     .attr("width", (d) -> chrPixelEnd[d] - chrPixelStart[d]+chrGap)
     .attr("height", (d) -> hInner)
     .attr("fill", (d) -> chrColor[d])
     .attr("stroke", "none")

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

  detailedLod = {}
  for i in data.chr
    detailedLod[i] = botsvg.append("g").append("path")
       .datum(data.lod[i].pos)
       .attr("d", botlodcurve(i))
       .attr("class", "thickline")
       .attr("stroke", "blue")
       .attr("opacity", 0)

  chrRect.on("mouseover", (d) ->
             d3.select(this).attr("fill", "#E9CFEC")
             detailedLod[d].attr("opacity", 1))
         .on("mouseout", (d) ->
             d3.select(this).attr("fill", chrColor[d])
             detailedLod[d].attr("opacity", 0))

  # chr labels
  topsvg.append("g").selectAll("empty")
    .data(data.chr)
    .enter()
    .append("text")
    .text((d) -> d)
    .attr("x", (d) -> Math.floor((chrPixelStart[d] + chrPixelEnd[d])/2))
    .attr("y", pad.top + hInner + pad.bottom*0.3)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "middle")

  # black borders
  topsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wInner)
     .attr("class", "outerBox")

  botsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botLwInner)
     .attr("class", "outerBox")

  botsvg.append("rect")
     .attr("x", botLw+pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", botRwInner)
     .attr("class", "outerBox")


# load json file and call draw function
d3.json("insulinlod.json", draw)
