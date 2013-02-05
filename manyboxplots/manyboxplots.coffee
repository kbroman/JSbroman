# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 1000
  h = 500
  pad = 20

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
     .attr("fill", "none")
     .attr("stroke", "black")
     .attr("stroke-width", 2)

  svg.append("path")
     .datum(data.ind)
     .attr("class", "line")
     .attr("d", quline(midQuant))
     .attr("fill", "none")
     .attr("stroke-width", "2")
     .attr("stroke", "black")

  colors = ["blue", "green", "orange", "red"]

  for j in [0..(midQuant-1)]
    svg.append("path")
       .datum(data.ind)
       .attr("class", "line")
       .attr("d", quline(j))
       .attr("fill", "none")
       .attr("stroke-width", "1")
       .attr("stroke", colors[j])

  for j in [(midQuant+1)..(nQuant-1)]
    svg.append("path")
       .datum(data.ind)
       .attr("class", "line")
       .attr("d", quline(j))
       .attr("fill", "none")
       .attr("stroke-width", "1")
       .attr("stroke", colors[nQuant-1-j])

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
                .attr("class","unselected")

  indRect.on("mouseover", -> d3.select(this).attr("opacity", "1").attr("class", "selected"))
         .on("mouseout", -> d3.select(this).attr("opacity", "0").attr("class","unselected"))


# load json file and call draw function
d3.json("hypo.json", draw)
