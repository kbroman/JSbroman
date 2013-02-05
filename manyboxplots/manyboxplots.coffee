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
             .domain([-1, 1])
             .range([h-pad, pad])

  quline = (j) ->
    d3.svg.line()
        .x((d,i) -> xScale(i))
        .y((d) -> yScale(data.quant[j][d]))

  svg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  svg.append("rect")
     .attr("x", pad)
     .attr("y", pad)
     .attr("height", h-2*pad)
     .attr("width", w-2*pad)
     .attr("class", "line")
     .attr("stroke", "black")
     .attr("stroke-width", 3)


  colors = ["blue", "green", "orange", "red", "black"]
  for j in [3..0]
    colors.push(colors[j])

  for j in [0...nQuant]
    svg.append("path")
       .datum(data.ind)
       .attr("d", quline(j))
       .attr("class", "line")
       .attr("stroke", colors[j])

  indRect = svg.selectAll("rect.ind")
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


  for j in [0...nQuant]
    svg.selectAll("text.qu")
       .data(data.qu)
       .enter()
       .append("text")
       .attr("class", "qu")
       .text( (d) -> "#{d*100}%")
       .attr("x", w-pad*0.1)
       .attr("y", (d,i) -> h*(1 - (i+2)/(data.qu.length+3)))
       .attr("fill", (d,i) -> colors[i])
       .attr("text-anchor", "end")


# load json file and call draw function
d3.json("hypo.json", draw)
