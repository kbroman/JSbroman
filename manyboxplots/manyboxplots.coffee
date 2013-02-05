# function that does all of the work
draw = (data) ->

  w = 1000
  h = 500
  pad = 20

  console.log(data.ind.length)

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
     .attr("d", quline(4))
     .attr("fill", "none")
     .attr("stroke-width", "2")
     .attr("stroke", "black")

  colors = ["blue", "green", "orange", "red"]

  for j in [0..3]
    svg.append("path")
       .datum(data.ind)
       .attr("class", "line")
       .attr("d", quline(j))
       .attr("fill", "none")
       .attr("stroke-width", "1")
       .attr("stroke", colors[j])

  for j in [5..8]
    svg.append("path")
       .datum(data.ind)
       .attr("class", "line")
       .attr("d", quline(j))
       .attr("fill", "none")
       .attr("stroke-width", "1")
       .attr("stroke", colors[8-j])

# load json file and call draw function
d3.json("hypo.json", draw)
