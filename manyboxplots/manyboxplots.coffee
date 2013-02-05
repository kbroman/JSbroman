# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 1000
  h = 500
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

  axisFormat = d3.format(".2f")

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
  axis = svg.append("g")

  # axis: white lines
  axis.append("g").selectAll("line.axis")
     .data([-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1])
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
  axis.append("g").selectAll("text.axis")
     .data([-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1])
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> axisFormat(d))
     .attr("x", pad*0.9)
     .attr("y", (d) -> yScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "end")


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

  indRect = indRectGrp.selectAll("rect.ind")
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

  indRect.on("mouseover", -> d3.select(this).attr("opacity", "1"))
         .on("mouseout", -> d3.select(this).attr("opacity", "0"))


  # label quantiles on right
  rightAxis = svg.append("g")

  for j in [0...nQuant]
    rightAxis.selectAll("text.qu")
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


  # box around the outside
  svg.append("rect")
     .attr("x", pad)
     .attr("y", pad)
     .attr("height", h-2*pad)
     .attr("width", w-2*pad)
     .attr("stroke", "black")
     .attr("stroke-width", 2)
     .attr("fill", "none")


# load json file and call draw function
d3.json("hypo.json", draw)
