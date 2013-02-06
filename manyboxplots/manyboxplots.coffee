# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 1000
  h = 450
  pad = 40

  # number of quantiles
  nQuant = data.quant.length
  midQuant = (nQuant+1)/2 - 1

  xScale = d3.scale.linear()
             .domain([0, data.ind.length-1])
             .range([pad, w-pad])

  yScale = d3.scale.linear()
             .domain([-1.1, 1.1])
             .range([h-pad, pad])

  axisFormat2 = d3.format(".2f")
  axisFormat1 = d3.format(".1f")

  quline = (j) ->
    d3.svg.line()
        .x((d,i) -> xScale(i))
        .y((d) -> yScale(data.quant[j][d]))

  svg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  # gray background
  svg.append("rect")
     .attr("x", pad)
     .attr("y", pad)
     .attr("height", h-2*pad)
     .attr("width", w-2*pad)
     .attr("stroke", "none")
     .attr("fill", d3.rgb(200, 200, 200))

  # axis on left
  LaxisData = [-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1]
  Laxis = svg.append("g")

  # axis: white lines
  Laxis.append("g").selectAll("empty")
     .data(LaxisData)
     .enter()
     .append("line")
     .attr("class", "line")
     .attr("class", "axis")
     .attr("x1", pad)
     .attr("x2", w-pad)
     .attr("y1", (d) -> yScale(d))
     .attr("y2", (d) -> yScale(d))
     .attr("stroke", "white")

  # axis: labels
  Laxis.append("g").selectAll("empty")
     .data(LaxisData)
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> axisFormat2(d))
     .attr("x", pad*0.9)
     .attr("y", (d) -> yScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "end")


  # axis on left
  BaxisData = [50, 100, 150, 200, 250, 300, 350, 400, 450]
  Baxis = svg.append("g")

  # axis: white lines
  Baxis.append("g").selectAll("empty")
     .data(BaxisData)
     .enter()
     .append("line")
     .attr("class", "line")
     .attr("class", "axis")
     .attr("y1", pad)
     .attr("y2", h-pad)
     .attr("x1", (d) -> xScale(d))
     .attr("x2", (d) -> xScale(d))
     .attr("stroke", "white")

  # axis: labels
  Baxis.append("g").selectAll("empty")
     .data(BaxisData)
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> d)
     .attr("y", h-pad*0.7)
     .attr("x", (d) -> xScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")


  # curves for quantiles
  colors = ["blue", "green", "orange", "red", "black"]
  for j in [3..0]
    colors.push(colors[j])

  curves = svg.append("g")

  for j in [0...nQuant]
    curves.append("path")
       .datum(data.ind)
       .attr("d", quline(j))
       .attr("class", "line")
       .attr("stroke", colors[j])

  # vertical rectangles representing each array
  indRectGrp = svg.append("g")

  indRect = indRectGrp.selectAll("empty")
                 .data(data.ind)
                 .enter()
                 .append("rect")
                 .attr("x", (d,i) -> xScale(i-0.5))
                 .attr("y", (d) -> yScale(data.quant[nQuant-1][d]))
                 .attr("width", 2)
                 .attr("height", (d) ->
                    yScale(data.quant[0][d]) - yScale(data.quant[nQuant-1][d]))
                 .attr("fill", "purple")
                 .attr("stroke", "none")
                 .attr("opacity", "0")

  # label quantiles on right
  rightAxis = svg.append("g")

  rightAxis.selectAll("empty")
       .data(data.qu)
       .enter()
       .append("text")
       .attr("class", "qu")
       .text( (d) -> "#{d*100}%")
       .attr("x", w-pad*0.1)
       .attr("y", (d,i) -> yScale((i+0.5)/nQuant - 0.5))
       .attr("fill", (d,i) -> colors[i])
       .attr("text-anchor", "end")
       .attr("dominant-baseline", "middle")


  # white box above to smother overlap
  svg.append("rect")
     .attr("x", 0)
     .attr("y", 0)
     .attr("width", w)
     .attr("height", pad)
     .attr("stroke", "none")
     .attr("fill", "white")

  # box around the outside
  svg.append("rect")
     .attr("x", pad)
     .attr("y", pad)
     .attr("height", h-2*pad)
     .attr("width", w-2*pad)
     .attr("stroke", "black")
     .attr("stroke-width", 2)
     .attr("fill", "none")

  # lower svg
  lowsvg = d3.select("body").append("svg")
             .attr("height", h)
             .attr("width", w)

  lowxScale = d3.scale.linear()
             .domain([-2, 2])
             .range([pad, w-pad])

  maxCount = 0;
  for i of data.counts
    for j of data.counts[i]
      maxCount = data.counts[i][j] if data.counts[i][j] > maxCount

  lowyScale = d3.scale.linear()
             .domain([0, maxCount+0.5])
             .range([h-pad, pad])

  # gray background
  lowsvg.append("rect")
     .attr("x", pad)
     .attr("y", pad)
     .attr("height", h-2*pad)
     .attr("width", w-2*pad)
     .attr("stroke", "none")
     .attr("fill", d3.rgb(200, 200, 200))

  # axis on left
  lowBaxisData = [-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2]
  lowBaxis = lowsvg.append("g")

  # axis: white lines
  lowBaxis.append("g").selectAll("empty")
     .data(lowBaxisData)
     .enter()
     .append("line")
     .attr("class", "line")
     .attr("class", "axis")
     .attr("y1", pad)
     .attr("y2", w-pad)
     .attr("x1", (d) -> lowxScale(d))
     .attr("x2", (d) -> lowxScale(d))
     .attr("stroke", "white")

  # axis: labels
  lowBaxis.append("g").selectAll("empty")
     .data(lowBaxisData)
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> axisFormat1(d))
     .attr("y", h-pad*0.7)
     .attr("x", (d) -> lowxScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")

  histline = d3.svg.line()
        .x((d,i) -> lowxScale(data.br[i]))
        .y((d) -> lowyScale(d))

  randomInd = data.ind[Math.floor(Math.random()*data.ind.length)]

  hist = lowsvg.append("path")
    .datum(data.counts[randomInd])
       .attr("d", histline)
       .attr("id", "histline")
       .attr("fill", "none")
       .attr("stroke", "purple")
       .attr("stroke-width", "2")


  lowsvg.append("text")
        .datum(randomInd)
        .attr("x", w/2)
        .attr("y", pad/2)
        .text((d) -> d)
        .attr("id", "histtitle")
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "middle")

  indRect
    .on("mouseover", (d) ->
              d3.select(this).attr("opacity", "1")
              d3.select("#histline")
                 .datum(data.counts[d])
                 .attr("d", histline)
              d3.select("#histtitle")
                 .datum(d)
                 .text((d) -> d)
            )
    .on("mouseout", (d) ->
              d3.select(this).attr("opacity", "0")
            )

  # box around the outside
  lowsvg.append("rect")
     .attr("x", pad)
     .attr("y", pad)
     .attr("height", h-2*pad)
     .attr("width", w-2*pad)
     .attr("stroke", "black")
     .attr("stroke-width", 2)
     .attr("fill", "none")



# load json file and call draw function
d3.json("hypo.json", draw)
