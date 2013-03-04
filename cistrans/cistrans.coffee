# function that does all of the work
draw = (data) ->

  # dimensions of panels
  w = [800, 300]
  h = [w[0], 300]
  pad = {left:60, top:40, right:40, bottom: 40}
  w = [w[0], w[0] + w[1] + pad.left + pad.right, w[1]]
  h = [h[0], h[1], h[0]]

  left = [pad.left, pad.left,
          pad.left + w[0] + pad.right + pad.left]
  top =  [pad.top,
          pad.top + h[0] + pad.bottom + pad.top,
          pad.top]
  right = []
  bottom = []
  for i of left
    right[i] = left[i] + w[i]
    bottom[i] = top[i] + h[i]

  totalw = right[2] + pad.right
  totalh = bottom[1] + pad.bottom

  # Size of rectangles in top-left panel
  peakRad = 2
  bigRad = 5

  # gap between chromosomes in lower plot
  chrGap = 8

  # height of marker ticks in lower panel
  tickHeight = (bottom[1] - top[1])*0.02

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

  # calculate X and Y scales, using cM positions
  totalChrLength = 0;
  for c in data.chrnames
    data.chr[c].length_cM = data.chr[c].end_cM - data.chr[c].start_cM
    totalChrLength += data.chr[c].length_cM

  chrXScale = {}
  chrYScale = {}
  curXPixel = left[0]+peakRad
  curYPixel = bottom[0]-peakRad
  for c in data.chrnames
    data.chr[c].length_pixel = Math.round((w[0]-peakRad*2) * data.chr[c].length_cM / totalChrLength)
    data.chr[c].start_Xpixel = curXPixel
    data.chr[c].end_Xpixel = curXPixel + data.chr[c].length_pixel - 1
    data.chr[c].start_Ypixel = curYPixel
    data.chr[c].end_Ypixel = curYPixel - (data.chr[c].length_pixel - 1)

    chrXScale[c] = d3.scale.linear()
                  .domain([data.chr[c].start_cM, data.chr[c].end_cM])
                  .range([data.chr[c].start_Xpixel, data.chr[c].end_Xpixel])
                  .clamp(true)
    chrYScale[c] = d3.scale.linear()
                  .domain([data.chr[c].start_cM, data.chr[c].end_cM])
                  .range([data.chr[c].start_Ypixel, data.chr[c].end_Ypixel])
                  .clamp(true)

    curXPixel += data.chr[c].length_pixel
    curYPixel -= data.chr[c].length_pixel

  # slight adjustments
  top[0] = data.chr["X"].end_Ypixel-peakRad
  right[1] = right[0] = data.chr["X"].end_Xpixel+peakRad
  h[0] = bottom[0] - top[0]
  data.chr["1"].start_Xpixel = left[0]
  data.chr["1"].start_Ypixel = bottom[0]
  data.chr["X"].end_Xpixel = right[0]
  data.chr["X"].end_Ypixel = top[0]

  # chr scales in lower figure
  chrLowXScale = {}
  cur = Math.round(pad.left + chrGap/2)
  for c in data.chrnames
    data.chr[c].start_lowerXpixel = cur
    data.chr[c].end_lowerXpixel = cur + Math.round((w[1]-chrGap*(data.chrnames.length))/totalChrLength*data.chr[c].length_cM)
    chrLowXScale[c] = d3.scale.linear()
                        .domain([data.chr[c].start_cM, data.chr[c].end_cM])
                        .range([data.chr[c].start_lowerXpixel, data.chr[c].end_lowerXpixel])
    cur = data.chr[c].end_lowerXpixel + chrGap

  # slight adjustments
  data.chr["1"].start_lowerXpixel = left[1]
  data.chr["X"].end_lowerXpixel = right[1]


  # create SVGs
  svg = d3.select("div#cistrans").append("svg")
          .attr("width", totalw)
          .attr("height", totalh)

  # gray backgrounds
  for j of left
    svg.append("rect")
       .attr("x", left[j])
       .attr("y", top[j])
       .attr("height", h[j])
       .attr("width", w[j])
       .attr("class", "innerBox")

  # add dark gray rectangles to define chromosome boundaries as checkerboard
  checkerboard = svg.append("g").attr("id", "checkerboard")
  for ci,i in data.chrnames
    for cj,j in data.chrnames
      if((i + j) % 2 == 0)
        checkerboard.append("rect")
           .attr("x", data.chr[ci].start_Xpixel)
           .attr("width", data.chr[ci].end_Xpixel - data.chr[ci].start_Xpixel)
           .attr("y", data.chr[cj].end_Ypixel)
           .attr("height", data.chr[cj].start_Ypixel - data.chr[cj].end_Ypixel)
           .attr("stroke", "none")
           .attr("fill", darkGray)
           .style("pointer-events", "none")

  # same in lower panel
  checkerboard2 = svg.append("g").attr("id", "checkerboard2")
  for ci,i in data.chrnames
      if(i % 2 == 0)
        checkerboard2.append("rect")
           .attr("x", data.chr[ci].start_lowerXpixel)
           .attr("width", data.chr[ci].end_lowerXpixel - data.chr[ci].start_lowerXpixel)
           .attr("y", top[1])
           .attr("height", h[1])
           .attr("stroke", "none")
           .attr("fill", darkGray)
           .style("pointer-events", "none")

  # use just the peaks with LOD > 10
  tmp = []
  for p in data.peaks
    tmp.push(p) if p.lod > 10
  data.peaks = tmp

  # maximum lod score
  maxlod = d3.max(data.peaks, (d) -> d.lod)

  # sort peaks to have increasing LOD score
  data.peaks = data.peaks.sort (a,b) ->
    return if a.lod < b.lod then -1 else +1

  # LOD score controls opacity
  Zscale = d3.scale.linear()
             .domain([0, 25])
             .range([0, 1])

  # Using https://github.com/Caged/d3-tip
  #   [slightly modified in https://github.com/kbroman/d3-tip]
  eqtltip = d3.svg.tip()
                 .orient("right")
                 .padding(3)
                 .text((z) -> "#{z.probe} (LOD = #{d3.format('.2f')(z.lod)})")
                 .attr("class", "d3-tip")
                 .attr("id", "eqtltip")


  # function for drawing lod curve for probe
  draw_probe = (probe_data) ->
    console.log("click! #{probe_data.probe}")

  # circles at eQTL peaks
  peaks = svg.append("g").attr("id", "peaks")
             .selectAll("empty")
             .data(data.peaks)
             .enter()
             .append("circle")
             .attr("cx", (d) -> chrXScale[d.chr](d.pos_cM))
             .attr("cy", (d) -> chrYScale[data.probes[d.probe].chr](data.probes[d.probe].pos_cM))
             .attr("r", peakRad)
             .attr("stroke", "none")
             .attr("fill", "darkslateblue")
             .attr("opacity", (d) -> Zscale(d.lod))
             .on "mouseover", (d) ->
                 d3.select(this).attr("r", bigRad)
                                .attr("fill", "hotpink")
                                .attr("stroke", "darkslateblue")
                                .attr("stroke-width", 1)
                                .attr("opacity", 1)
                 eqtltip.call(this,d)
             .on "mouseout", (d) ->
                 d3.select(this).attr("r", peakRad)
                                .attr("fill", "darkslateblue")
                                .attr("stroke", "none")
                                .attr("opacity", (d) -> Zscale(d.lod))
                 d3.selectAll("#eqtltip").remove()
             .on "click", (d) ->
                 d3.json("data/probe_data/probe#{d.probe}.json", draw_probe)


  # black borders
  for j of left
    svg.append("rect")
       .attr("x", left[j])
       .attr("y", top[j])
       .attr("height", h[j])
       .attr("width", w[j])
       .attr("class", "outerBox")

# load json file and call draw function
d3.json("data/insulin_eqtl.json", draw)
