# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 500
  h = 700
  pad = {left:60, top:20, right:40, bottom: 40}
  wInner = w - pad.left - pad.right
  hInner = h - pad.top - pad.bottom
  wL = 300
  wLInner = wL - pad.left - pad.right

  leftsvg = d3.select("body").append("svg")
              .attr("id", "leftsvg")
              .attr("width", wL)
              .attr("height", h)
  rightsvg = d3.select("body").append("svg")
              .attr("id", "rightsvg")
              .attr("width", w)
              .attr("height", h)

  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "#E9CFEC"
  purple = "#8C4374"

  # gray backgrounds
  leftsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wLInner)
     .attr("class", "innerBox")
     .style("pointer-events", "none")
  rightsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wInner)
     .attr("class", "innerBox")
     .style("pointer-events", "none")

  # info for scales
  nmarkers = data.markers.length
  pheMin = d3.min(data.pheno)
  pheMax = d3.max(data.pheno)
  ngen = data.genonames.length

  # scales
  leftyScale = d3.scale.ordinal()
                 .domain(d3.range(nmarkers))
                 .rangePoints([pad.top, pad.top+hInner], 1)
  xScale = d3.scale.ordinal()
                 .domain(d3.range(ngen))
                 .rangePoints([pad.left, pad.left+wInner], 1)
  yScale = d3.scale.linear()
                 .domain([pheMin, pheMax])
                 .range([pad.top + hInner*0.98, pad.top + hInner*0.02])

  # keep track of which marker is clicked
  clicked = {}
  for m of data.markers
    clicked[m] = 0

  # horizontal jitter for genotype points
  jitterAmount = (xScale(1) - xScale(0))/6
  jitter = []
  for i of data.geno
    jitter[i] = (2.0*Math.random()-1.0) * jitterAmount

  # pick random marker for initial plot
  curMarker = data.markers[Math.floor(Math.random()*nmarkers)]
  console.log(curMarker)

  rightsvg.append("text")
          .attr("id", "rightTitle")
          .text(curMarker)
          .attr("x", pad.left + wInner/2)
          .attr("y", pad.top/2)

  # mouseover/mouseout for selecting markers
  mouseover = (m) ->
     d3.select(this).attr("fill", pink) unless clicked[m]

  mouseout = (m) ->
     d3.select(this).attr("fill", purple).attr("stroke", "none") unless clicked[m]

  click = (m) ->
    clicked[m] = 1
    unless(curMarker is "")
      clicked[curMarker] = 0
      d3.select("#circle#{curMarker}").attr("fill", purple).attr("stroke", "none")
    d3.select(this).attr("fill", pink).attr("stroke", purple)
    d3.select("#rightTitle").text(m)
    curMarker = m
    rightdots.transition().duration(1000).attr("cx", (d,i) -> xScale(data.geno[i][curMarker]) + jitter[i])

  # dots and text to left
  markerdots = leftsvg.selectAll("empty")
                      .data(data.markers)
                      .enter()
                      .append("circle")
                      .attr("id", (d) -> "circle#{d}")
                      .attr("cx", pad.left + wLInner/2 - 20)
                      .attr("cy", (d,i) -> leftyScale(i))
                      .attr("r", 6)
                      .attr("fill", purple)
                      .attr("stroke", "none")
                      .attr("stroke-width", "2")
                      .on("mouseover", mouseover)
                      .on("mouseout", mouseout)
                      .on("click", click)

  leftsvg.selectAll("empty")
         .data(data.markers)
         .enter()
         .append("text")
         .text((d) -> d)
         .attr("x", pad.left + wLInner/2 + 20)
         .attr("y", (d,i) -> leftyScale(i))

  # select initial marker
  clicked[curMarker] = 1
  d3.select("#circle#{curMarker}").attr("fill", pink).attr("stroke", purple)

  # phenotype/genotype dots
  rightdots = rightsvg.selectAll("empty")
                      .data(data.pheno)
                      .enter()
                      .append("circle")
                      .attr("cx", (d,i) -> xScale(data.geno[i][curMarker]) + jitter[i])
                      .attr("cy", (d) -> yScale(d))
                      .attr("r", "4")
                      .attr("fill", darkGray)
                      .attr("stroke", "black")
                      .attr("stroke-width", "2")

  # black borders
  leftsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wLInner)
     .attr("class", "outerBox")
     .style("pointer-events", "none")
  rightsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", hInner)
     .attr("width", wInner)
     .attr("class", "outerBox")
     .style("pointer-events", "none")


# load json file and call draw function
d3.json("data.json", draw)
